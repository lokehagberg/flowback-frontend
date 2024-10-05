<script lang="ts">
	import { type PreviewMessage } from './interfaces';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Group } from '$lib/Group/interface';
	import Tab from '$lib/Generic/Tab.svelte';
	import type { User } from '$lib/User/interfaces';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { onMount } from 'svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { chatPreview as chatLimit } from '../Generic/APILimits.json';
	import { updateUserData } from './functions';

	let groups: Group[] = [],
		directs: any[] = [],
		user: User,
		chatSearch = '';

	export let selectedChat: number | null,
		selectedChatChannelId: number | null,
		selectedPage: 'direct' | 'group' = 'direct',
		previewDirect: PreviewMessage[] = [],
		previewGroup: PreviewMessage[] = [];

	onMount(async () => {
		//TODO: Get this from the userinfo sveltestore
		const { json, res } = await fetchRequest('GET', 'user');
		user = json;
		await getChattable();
		await setUpPreview();
	});

	const setUpPreview = async () => {
		previewDirect = await getPreview('user');
		previewGroup = await getPreview('group');
	};

	const getPreview = async (selectedPage: 'user' | 'group') => {
		const { res, json } = await fetchRequest(
			'GET',
			`chat/message/channel/preview/list?origin_name=${selectedPage}`
		);

		if (!res.ok) return [];
		return json.results;
	};

	const getChannelId = async (id: number) => {
		const { res, json } = await fetchRequest('GET', `user/chat/${id}`);
		return json.id;
	};

	const getChattable = async () => {
		if (directs.length + groups.length !== 0) return;

		directs = await getPeople();
		groups = await getGroups();
	};

	const getGroups = async () => {
		const { res, json } = await fetchRequest('GET', `group/list?joined=true&limit=${chatLimit}`);
		if (!res.ok) return [];
		return json.results;
	};

	const getPeople = async () => {
		const { json, res } = await fetchRequest('GET', `users?limit=${chatLimit}`);
		if (!res.ok) return [];
		let chatters = json.results.filter((chatter: any) => chatter.id !== user.id);
		chatters.map(async (chatter: any) => {
			chatter.channel_id = await getChannelId(chatter.id);
			return chatter;
		});
		return chatters;
	};

	const clickedChatter = async (chatter: any) => {
		//Update when user last saw message after clicking on channel

		if (selectedPage === 'direct') {
			// if (selectedChat) updateUserData(await getChannelId(selectedChat), null, new Date());
			let message = previewDirect.find((message) => message.channel_id === chatter.channel_id);

			if (message) {
				//Gets rid of existing notification when clicked on new chat
				message.timestamp = new Date().toString();
				message.notified = false;

				previewDirect = previewDirect;
			}
			selectedChat = chatter.channel_id;
			selectedChatChannelId = chatter.channel_id;
		} else if (selectedPage === 'group') {
			let message = previewGroup.find((message) => message.channel_id === chatter.chat_id);
			if (message) {
				//Gets rid of existing notification when clicked on new chat
				message.timestamp = new Date().toString();
				message.notified = false;

				previewGroup = previewGroup;
			}

			selectedChat = chatter.id;
			selectedChatChannelId = chatter.chat_id;
		}
	};

	//Puts chats with notification circle at the top
	//Puts chats with message between
	//Puts empty chats at the bottom
	//Siamand is doing this, to be changed drastically
	const sort = (chatter: Group[] | any[], preview: PreviewMessage[]) => {
		chatter.sort((a, b) => {
			let notifiedMsgA = preview.find((notified) => notified.channel_id === a.chat_id);
			let notifiedMsgB = preview.find((notified) => notified.channel_id === b.chat_id);

			// Handle cases where notifiedMsg might be undefined
			let notifiedA = notifiedMsgA?.notified || false;
			let notifiedB = notifiedMsgB?.notified || false;

			if (notifiedA === notifiedB) return 0; // If both are the same, they are considered equal
			return notifiedA ? -1 : 1; // If notifiedA is true, it should come before notifiedBF
		});
		return chatter;
	};

	$: groups = sort(groups, previewGroup);
</script>

<div class={`col-start-1 col-end-2 row-start-1 row-end-2 dark:bg-darkobject`}>
	<Tab
		Class={``}
		bind:selectedPage
		tabs={['direct', 'group']}
		displayNames={['Direct', 'Groups']}
	/>
</div>

<div class="max-h-[100%] overflow-scroll">
	<TextInput
		label={selectedPage === 'direct' ? 'Search users' : 'Search groups'}
		bind:value={chatSearch}
		Class="mt-1 ml-2 mb-2 w-7/12"
	/>
	{#each selectedPage === 'direct' ? directs : groups as chatter}
		{@const previewObject =
			selectedPage === 'direct'
				? previewDirect.find((direct) => direct.channel_id === chatter.channel_id)
				: previewGroup.find((group) => group.channel_id === chatter.chat_id)}

		<div
			class:hidden={selectedPage === 'direct'
				? !chatter.username.toLowerCase().includes(chatSearch.toLowerCase())
				: !chatter.name.toLowerCase().includes(chatSearch.toLowerCase())}
			class="transition transition-color p-3 flex items-center gap-3 hover:bg-gray-200 active:bg-gray-500 cursor-pointer dark:bg-darkobject dark:hover:bg-darkbackground"
			class:bg-gray-200={selectedChat === chatter.id}
			class:dark:bg-gray-700={selectedChat === chatter.id}
			on:click={() => {
				clickedChatter(chatter);
			}}
			on:keydown
			tabindex="0"
			role="button"
		>
			<!-- {@debug  previewGroup} -->
			<!-- Notification Symbol -->
			{#if previewObject?.notified}
				<div
					class="p-1 rounded-full"
					class:bg-blue-300={selectedPage === 'group'}
					class:bg-purple-300={selectedPage === 'direct'}
				/>
			{/if}
			<ProfilePicture
				username={chatter.name || chatter.username}
				profilePicture={chatter.profile_image}
			/>
			<div class="flex flex-col">
				<span class="max-w-[12vw] overflow-x-hidden overflow-ellipsis"
					>{chatter.name || chatter.username}</span
				>
				<span class="text-gray-400 text-sm truncate h-[20px] overflow-x-hidden max-w-[10vw]">
					<!-- {@debug previewObject} -->

					{#if previewObject}
						{previewObject.user.username}:
						{previewObject.message}
					{/if}
				</span>
			</div>
		</div>
	{/each}
</div>

<style>
	.group-message-bg {
		background: linear-gradient(90deg, rgba(255, 255, 255, 1) 32%, rgba(180, 210, 255, 1) 76%);
	}

	.direct-message-bg {
		background: linear-gradient(90deg, rgb(240, 224, 255) 32%, rgb(255, 255, 255) 76%);
	}

	.both-message-bg {
		background: linear-gradient(90deg, rgb(240, 224, 255) 32%, rgba(180, 210, 255, 1) 76%);
	}
</style>

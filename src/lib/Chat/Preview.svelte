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
		selectedPage: 'direct' | 'group' = 'direct',
		previewDirect: PreviewMessage[] = [],
		previewGroup: PreviewMessage[] = [];

	onMount(async () => {
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

		//TODO Make sure people see notifications as they enter
		let preview = json.results.map((prev: PreviewMessage) => {
			console.log(
				prev.timestamp,
				prev.created_at,
				prev.updated_at,
				new Date(prev.timestamp) < new Date(prev.created_at)
			);
			prev.notified = new Date(prev.timestamp) < new Date(prev.created_at);
			return prev;
		});

		// console.log(preview, 'PREIVIEI');

		return json.results;
	};

	const getChattable = async () => {
		if (directs.length + groups.length !== 0) return;

		directs = await getPeople();
		groups = await getGroups();
	};

	const getGroups = async () => {
		const { res, json } = await fetchRequest('GET', `group/list?joined=true&limit=${chatLimit}`);
		return json.results;
	};

	const getPeople = async () => {
		const { json, res } = await fetchRequest('GET', `users?limit=${chatLimit}`);
		return json.results.filter((chatter: any) => chatter.id !== user.id);
	};

	const clickedChatter = (chatter: any) => {
		//Update when user last saw message after clicking on channel
		if (selectedChat) updateUserData(selectedChat, null, new Date());

		if (selectedPage === 'direct') {
			let message = previewDirect.find((message) => message.channel_id === selectedChat);

			if (message) {
				//Gets rid of existing notification when clicked on new chat
				message.timestamp = new Date().toString();
				message.notified = false;

				previewDirect = previewDirect;
			}
			selectedChat = chatter.id;
		} else if (selectedPage === 'group') {
			let message = previewGroup.find((message) => message.channel_id === selectedChat);
			if (message) {
				//Gets rid of existing notification when clicked on new chat
				message.timestamp = new Date().toString();
				message.notified = false;

				previewGroup = previewGroup;
			}
			selectedChat = chatter.chat_id;
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

<!-- ${
	(previewDirect.find(preview => preview.notified) && previewGroup.find(preview => preview.notified))
		? 'both-message-bg'
		: previewDirect.find(preview => preview.notified)
		? 'direct-message-bg'
		: previewGroup.find(preview => preview.notified)
		? 'group-message-bg'
		: ''}
		
		`} -->
<div class={`col-start-1 col-end-2 row-start-1 row-end-2 dark:bg-darkobject`}>
	<Tab
		Class={``}
		bind:selectedPage
		tabs={['direct', 'group']}
		displayNames={['Direct', 'Groups']}
	/>
</div>

<ul
	class="row-start-2 row-end-4 overflow-hidden bg-white dark:bg-darkobject flex flex-col sm:h-[30-vh] md:h-[80vh] lg:h-[90vh] overflow-y-scroll pb-[40px]"
>
	<TextInput
		label={selectedPage === 'direct' ? 'Search users' : 'Search groups'}
		bind:value={chatSearch}
		Class="mt-1 ml-2 mb-2 w-7/12"
	/>
	{#each selectedPage === 'group' ? groups : directs as chatter}
		{@const previewObject =
			selectedPage === 'group'
				? previewGroup.find((group) => group.channel_id === chatter.chat_id)
				: previewDirect.find((direct) => direct.channel_id === chatter.id)}

		<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
		<li
			class:hidden={selectedPage === 'direct'
				? !chatter.username.toLowerCase().includes(chatSearch.toLowerCase())
				: !chatter.name.toLowerCase().includes(chatSearch.toLowerCase())}
			class="transition transition-color p-3 flex items-center gap-3 hover:bg-gray-200 active:bg-gray-500 cursor-pointer dark:bg-darkobject dark:hover:bg-darkbackground"
			class:bg-gray-200={selectedChat === chatter.id}
			on:keydown
			on:click={async () => {
				clickedChatter(chatter);
				setTimeout(() => {
					// Fixes having to doubble click to get rid of chat notificattion
					clickedChatter(chatter);
				}, 300);
			}}
		>
			<!-- {@debug  previewGroup} -->
			<!-- Notification Symbol -->
			{#if previewObject?.notified}
				<div class="p-1 rounded-full"
				class:bg-blue-300={selectedPage === "group"}
				class:bg-purple-300={selectedPage === "direct"}
				/>
			{/if}

			<ProfilePicture user={chatter} />
			<div class="flex flex-col">
				<span class="max-w-[12vw] overflow-x-hidden overflow-ellipsis"
					>{chatter.name || chatter.username}</span
				>
				<span class="text-gray-400 text-sm truncate h-[20px] overflow-x-hidden max-w-[10vw]">
					{previewObject?.message || ''}
				</span>
			</div>
		</li>
	{/each}
</ul>

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

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
		previewDirect = await getPreview('direct');
		previewGroup = await getPreview('group');
	};

	const getPreview = async (selectedPage: 'direct' | 'group') => {
		const { res, json } = await fetchRequest(
			'GET',
			`chat/message/channel/preview/list?origin_name=group`
		);

		if (!res.ok) return [];

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
		if (selectedChat) updateUserData(selectedChat, null, new Date());
		//Gets rid of existing notification when clicked on new chat

		if (selectedPage === 'direct') {
			//TODO-user more advanced typescript features to make sure I don't have to use ts-ignore here
			//@ts-ignore
			let message = previewDirect?.find(
				(message) => message.target_id === selectedChat || message.user_id === selectedChat
			);
			if (message) {
				message.timestamp = new Date().toString();
				previewDirect = previewDirect;
			}
		} else if (selectedPage === 'group') {
			let message = previewGroup.find((message) => message.group_id === selectedChat);
			if (message) message.timestamp = new Date().toString();
			previewGroup = previewGroup;
		}

		//Switches chat shown to the right of the screen to chatter
		if (selectedPage === 'direct') selectedChat = chatter.id;
		else if (selectedPage === 'group') selectedChat = chatter.chat_id;

		// setTimeStamp(chatter.id, selectedPage);
	};

	//Puts chats with notification circle at the top
	//Puts chats with message between
	//Puts empty chats at the bottom
	//Siamand is doing this, to be changed drastically
	const sort = (chatter: any[], preview: PreviewMessage[], notified: number[]) => {
		chatter.sort((direct) => {
			let notifiedMsg = notified.find((notified) => notified === direct.id);

			if (notifiedMsg) return -1;

			var previewMsg = preview?.find(
				(preview) =>
					(preview.target_id === direct.id && preview.user_id === user.id) ||
					(preview.target_id === user.id && preview.user_id === direct.id)
			);
			if (previewMsg) return 0;
			return 1;
		});
		return chatter;
	};

	const getMessage = (chatter: any) => {
		return (
			(selectedPage === 'direct' ? previewDirect : previewGroup).find(
				(message) =>
					(user.id !== message.target_id &&
						message.target_id === chatter.id &&
						selectedPage === 'direct') ||
					(user.id !== message.user_id &&
						message.user_id === chatter.id &&
						selectedPage === 'direct') ||
					(message.group_id === chatter.id && selectedPage === 'group')
			)?.message || ''
		);
	};

	$: console.log(previewGroup, 'LÖE CHANGE?');
</script>

<!-- // ${
// 	notifiedDirect.length && notifiedGroup.length
// 		? 'both-message-bg'
// 		: notifiedDirect.length > 0
// 		? 'direct-message-bg'
// 		: notifiedGroup.length > 0
// 		? 'group-message-bg'
// 		: 'bg-white'
// }` -->
<div class={`col-start-1 col-end-2 row-start-1 row-end-2 dark:bg-darkobject`}>
	<Tab
		Class={``}
		bind:selectedPage
		tabs={['direct', 'group']}
		displayNames={['Direct', 'Groups']}
	/>
</div>

<ul
	class="row-start-2 row-end-4 bg-white dark:bg-darkobject flex flex-col sm:h-[30-vh] md:h-[80vh] lg:h-[90vh] overflow-y-scroll"
>
	<TextInput
		label={selectedPage === 'direct' ? 'Search users' : 'Search groups'}
		bind:value={chatSearch}
		Class="mt-1 ml-2 mb-2 w-7/12"
	/>
	{#each selectedPage === 'direct' ? directs : groups as chatter}
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
			}}
		>
			<!-- {previewGroup.find((group) => {
				console.log(group, chatter, 'GORUPSCHATER');
				group.id === chatter.id;
			})}
 -->
			<!-- {@debug previewGroup} -->
			{#key previewGroup}
				{#if previewGroup.find((group) => 
					group.channel_id === chatter.chat_id
					&& group.notified === true
					)}
					<div class="p-1 rounded-full bg-blue-300" />
				<!-- {:else } -->
					<!-- IT WORKKS ITS TRUE -->
				{/if}
			{/key}

			<ProfilePicture user={chatter} />
			<div class="flex flex-col">
				<span class="max-w-[12vw] overflow-x-hidden overflow-ellipsis"
					>{chatter.name || chatter.username}</span
				>
				<span class="text-gray-400 text-sm truncate h-[20px] overflow-x-hidden max-w-[10vw]">
					{getMessage(chatter)}
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

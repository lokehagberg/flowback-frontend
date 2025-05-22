<script lang="ts">
	import ChatWindow from './ChatWindow.svelte';
	import Preview from './Preview.svelte';
	import { onMount } from 'svelte';
	import type { GroupMembers, Message, PreviewMessage } from './interfaces';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { User } from '$lib/User/interfaces';
	import { _ } from 'svelte-i18n';
	import { env } from '$env/dynamic/public';
	import Fa from 'svelte-fa';
	import Button from '$lib/Generic/Button.svelte';
	import { faCog, faX } from '@fortawesome/free-solid-svg-icons';
	import ChatIcon from '$lib/assets/Chat_fill.svg';
	import { darkModeStore, getIconFilter } from '$lib/Generic/DarkMode';
	import { chatPartner, isChatOpen } from './ChatStore.svelte';
	import { goto } from '$app/navigation';
	import CreateChatGroup from '$lib/Chat/CreateChatGroup.svelte';
	import { updateUserData } from './functions';

	let messages: Message[] = [],
		chatOpen = env.PUBLIC_MODE === 'DEV' ? false : false,
		user: User,
		selectedPage: 'direct' | 'group' = 'direct',
		selectedChat: number | null,
		previewDirect: PreviewMessage[] = [],
		previewGroup: PreviewMessage[] = [],
		isLookingAtOlderMessages = false,
		chatDiv: HTMLDivElement,
		selectedChatChannelId: number | null,
		darkMode = false,
		creatingGroup = false,
		groupMembers: GroupMembers[] = [];

	// Reactive variables to track unread messages
	$: hasUnreadDirect = previewDirect.some((p) => p.notified);
	$: hasUnreadGroup = previewGroup.some((p) => p.notified);

	// Clear notification and update localStorage timestamp when a chat is opened
	const clearChatNotification = async (chatterId: number | null, page: 'direct' | 'group') => {
		if (!chatterId) return;

		// Store the current timestamp in localStorage to mark the chat as read
		const timestampKey = `lastInteraction_${chatterId}`;
		const now = new Date().toISOString();
		localStorage.setItem(timestampKey, now);

		// console.log("clear timestampKey", localStorage.getItem(timestampKey));

		// Update server-side timestamp
		await updateUserData(chatterId, new Date(), new Date());

		// Clear notification for direct messages
		if (page === 'direct') {
			let message = previewDirect.find((message) => message.channel_id === chatterId);
			if (message) {
				message.timestamp = new Date().toString();
				message.notified = false;
				previewDirect = [...previewDirect];
			}
		// Clear notification for group messages
		} else if (page === 'group') {
			let message = previewGroup.find((message) => message.channel_id === chatterId);
			if (message) {
				message.timestamp = new Date().toString();
				message.notified = false;
				previewGroup = [...previewGroup];
			}
		}
	};

	onMount(async () => {
		// Fetch user data on component mount
		await getUser();
		// Adjust chat window margin based on header height
		correctMarginRelativeToHeader();
		window.addEventListener('resize', correctMarginRelativeToHeader);
		// Subscribe to dark mode changes
		darkModeStore.subscribe((dm) => (darkMode = dm));
		// Subscribe to chat open state
		isChatOpen.subscribe((open) => (chatOpen = open));

		// Periodically clean up notifications older than 1 hour
		const cleanupNotifications = () => {
			const now = new Date();
			previewDirect = previewDirect.map((p) => {
				if (p.notified && new Date(p.created_at).getTime() < now.getTime() - 3600000) {
					p.notified = false;
				}
				return p;
			});
			previewGroup = previewGroup.map((p) => {
				if (p.notified && new Date(p.created_at).getTime() < now.getTime() - 3600000) {
					p.notified = false;
				}
				return p;
			});
		};

		const interval = setInterval(cleanupNotifications, 60000);
		return () => clearInterval(interval);
	});

	// Adjust chat window margin dynamically
	const correctMarginRelativeToHeader = () => {
		const _headerHeight = document.querySelector('#header')?.clientHeight;
		if (_headerHeight && chatDiv) chatDiv.style.marginTop = `${_headerHeight.toString()}px`;
	};

	// Fetch current user data
	const getUser = async () => {
		const { res, json } = await fetchRequest('GET', 'user');
		if (!res.ok) return;
		user = json;
	};

	// Automatically select the first chat when the chat window opens
	$: if (chatOpen && selectedChat === null && selectedChatChannelId === null) {
		if (selectedPage === 'direct' && previewDirect.length > 0) {
			const firstDirectChat = previewDirect[0];
			selectedChat = firstDirectChat.channel_id;
			selectedChatChannelId = firstDirectChat.channel_id;
			chatPartner.set(firstDirectChat.channel_id);
			// Clear notification and update timestamp for the selected chat
			clearChatNotification(firstDirectChat.channel_id, 'direct');
		} else if (selectedPage === 'group' && previewGroup.length > 0) {
			const firstGroupChat = previewGroup[0];
			selectedChat = firstGroupChat.channel_id;
			selectedChatChannelId = firstGroupChat.channel_id;
			chatPartner.set(firstGroupChat.channel_id);
			// Clear notification and update timestamp for the selected chat
			clearChatNotification(firstGroupChat.channel_id, 'group');
		}
	}

	// Reset chat partner when chat is closed
	$: if (!chatOpen) {
		chatPartner.set(0);
	}
</script>

<svelte:head>
	<title>
		{`${hasUnreadDirect ? '🟣' : ''}${hasUnreadGroup ? '🔵' : ''}`}
	</title>
</svelte:head>

<div
	bind:this={chatDiv}
	class:invisible={!chatOpen}
	class="bg-background dark:bg-darkbackground dark:text-darkmodeText fixed z-40 w-full h-[100vh] !flex justify-center"
>
	<Button
		onClick={() => {
			chatOpen = false;
			isChatOpen.set(false);
			goto('/user/settings');
		}}
		Class="absolute right-0 top-0 p-3 m-4 transition-all dark:bg-darkobject hover:brightness-95 active:brightness-90"
	>
		<div class="text-gray-800 dark:text-gray-200">
			<Fa icon={faCog} />
		</div>
	</Button>

	<Button
		onClick={() => {
			chatOpen = false;
			isChatOpen.set(false);
		}}
		Class="absolute left-0 top-0 p-3 m-4 transition-all dark:bg-darkobject hover:brightness-95 active:brightness-90"
	>
		<div class="text-gray-800 dark:text-gray-200">
			<Fa icon={faX} />
		</div>
	</Button>

	<div class="flex w-full gap-6 max-w-[1200px] h-[85vh]">
		<div class="bg-white w-[40%] flex-grow my-8 ml-6 dark:bg-darkobject p-2">
			{#key creatingGroup}
				<Preview
					bind:selectedChat
					bind:selectedPage
					bind:previewDirect
					bind:previewGroup
					bind:selectedChatChannelId
					bind:creatingGroup
					bind:groupMembers
				/>
			{/key}
		</div>
		<div class="bg-white w-[60%] flex-grow my-8 mr-6 dark:bg-darkobject p-2">
			{#if creatingGroup}
				<CreateChatGroup bind:creatingGroup bind:groupMembers />
			{:else}
				<ChatWindow
					bind:selectedChat
					bind:selectedChatChannelId
					bind:selectedPage
					bind:previewDirect
					bind:previewGroup
					bind:isLookingAtOlderMessages
					{user}
				/>
			{/if}
		</div>
	</div>
</div>

<button
	on:click={() => {
		chatOpen = !chatOpen;
		isChatOpen.set(chatOpen);
	}}
	class:small-notification={hasUnreadDirect}
	class:small-notification-group={hasUnreadGroup}
	class="dark:text-white transition-all fixed z-50 bg-white dark:bg-darkobject shadow-md border p-5 bottom-6 ml-5 rounded-full cursor-pointer hover:shadow-xl hover:border-gray-400 active:shadow-2xl active:p-6"
>
	{#key darkMode}
		<img
			src={ChatIcon}
			class="text-white"
			style="filter: {getIconFilter(true, 'white')}"
			alt={chatOpen ? 'close chat' : 'open chat'}
		/>
	{/key}
</button>

<style>
	.small-notification:before {
		position: absolute;
		content: '';
		top: 0;
		right: 0;
		background-color: rgb(167, 139, 250);
		border-radius: 100%;
		padding: 10px;
		z-index: 10;
	}

	.small-notification-group:after {
		position: absolute;
		content: '';
		top: 10px;
		right: 0;
		background-color: rgb(147, 197, 253);
		border-radius: 100%;
		padding: 10px;
	}
</style>
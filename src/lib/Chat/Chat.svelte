<script lang="ts">
	import ChatWindow from './ChatWindow.svelte';
	import Preview from './Preview.svelte';
	import { onMount } from 'svelte';
	import type { Message, PreviewMessage } from './interfaces';
	import { faComment } from '@fortawesome/free-solid-svg-icons/faComment';
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

	let messages: Message[] = [],
		chatOpen = env.PUBLIC_MODE === 'DEV' ? false : false,
		user: User,
		// Specifies which chat window is open
		selectedPage: 'direct' | 'group' = 'direct',
		selectedChat: number | null,
		//The preview page on the left side of the chat screen
		previewDirect: PreviewMessage[] = [],
		previewGroup: PreviewMessage[] = [],
		notifiedDirect: number[] = [],
		notifiedGroup: number[] = [],
		isLookingAtOlderMessages = false,
		chatDiv: HTMLDivElement,
		selectedChatChannelId: number | null,
		darkMode = false;

	onMount(async () => {
		await getUser();
		correctMarginRelativeToHeader();
		window.addEventListener('resize', correctMarginRelativeToHeader);
		darkModeStore.subscribe((dm) => (darkMode = dm));
		isChatOpen.subscribe((open) => (chatOpen = open));
		chatPartner.subscribe((partner) => (selectedChat = partner));
	});

	const correctMarginRelativeToHeader = () => {
		const _headerHeight = document.querySelector('#header')?.clientHeight;
		if (_headerHeight && chatDiv) chatDiv.style.marginTop = `${_headerHeight.toString()}px`;
	};

	//TODO: Turn all these get users into one unified svelte store for fewer API calls
	const getUser = async () => {
		const { res, json } = await fetchRequest('GET', 'user');
		if (!res.ok) return;
		user = json;
	};

	// $: if (!chatOpen) {
	// 	if (selectedChat) updateUserData(selectedChat, null, new Date());
	// 	selectedChat = null;
	// 	// selectedPage === 'direct';
	// }
</script>

<svelte:head>
	<title>
		{`${notifiedDirect.length > 0 ? '🟣' : ''}${notifiedGroup.length > 0 ? '🔵' : ''}`}
	</title>
</svelte:head>

<div
	bind:this={chatDiv}
	class:invisible={!chatOpen}
	class="bg-background dark:bg-darkbackground dark:text-darkmodeText fixed z-40 w-full h-[100vh] !flex justify-center"
>
	<Button
		action={() => {
			chatOpen = false;
			isChatOpen.set(false);
		}}
		Class="absolute left-0 top-0 p-3 m-4 transition-all dark:bg-darkobject hover:brightness-95 active:brightness-90"
	>
		<div class="text-gray-800 dark:text-gray-200">
			<Fa icon={faX} />
		</div>
	</Button>

	<!-- TODO: This will link to Chat settings once that has been implemented -->

	<Button
		action={() => {
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

	<div class="flex w-full gap-6 max-w-[1200px] h-[85vh]">
		<div class="bg-white w-[40%] flex-grow my-8 ml-6 dark:bg-darkobject p-2">
			<Preview
				bind:selectedChat
				bind:selectedPage
				bind:previewDirect
				bind:previewGroup
				bind:selectedChatChannelId
			/>
		</div>
		<div class="bg-white w-[60%] flex-grow my-8 mr-6 dark:bg-darkobject p-2">
			<ChatWindow
				bind:selectedChat
				bind:selectedChatChannelId
				bind:selectedPage
				bind:previewDirect
				bind:previewGroup
				bind:isLookingAtOlderMessages
				{user}
			/>
		</div>
	</div>
</div>

<!-- Button which launches the chat, visible in bottom left corner when not in chat -->
<button
	on:click={() => {
		chatOpen = true;
		isChatOpen.set(true);
	}}
	class:small-notification={previewDirect.find((preview) => preview.notified)}
	class:small-notification-group={previewGroup.find((preview) => preview.notified)}
	class="dark:text-white transition-all fixed z-30 bg-white dark:bg-darkobject shadow-md border p-5 bottom-6 ml-5 rounded-full cursor-pointer hover:shadow-xl hover:border-gray-400 active:shadow-2xl active:p-6"
>
	{#key darkMode}
		<img
			src={ChatIcon}
			class="text-white"
			style="filter: {getIconFilter(true, 'white')}"
			alt="open chat"
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
		background-color: rgb(147, 197, 235);
		border-radius: 100%;
		padding: 10px;
	}
</style>

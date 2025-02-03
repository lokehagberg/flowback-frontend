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
	import { faX } from '@fortawesome/free-solid-svg-icons';

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
		selectedChatChannelId: number | null;

	onMount(async () => {
		await getUser();
		correctMarginRelativeToHeader();
		window.addEventListener('resize', correctMarginRelativeToHeader);
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
		action={() => (chatOpen = false)}
		Class="absolute left-0 top-0 p-3 m-4 transition-all bg-white dark:bg-darkobject hover:brightness-95 active:brightness-90"
	>
		<div class="text-gray-800 dark:text-gray-200">
			<Fa icon={faX} />
		</div>
	</Button>

	<div class="flex w-full gap-6 max-w-[1200px] h-[85vh]">
		<div class="bg-white w-[40%] flex-grow my-12 ml-6 dark:bg-darkobject p-2">
			<Preview
				bind:selectedChat
				bind:selectedPage
				bind:previewDirect
				bind:previewGroup
				bind:selectedChatChannelId
			/>
		</div>
		<div class="bg-white w-[60%] flex-grow my-12 mr-6 dark:bg-darkobject p-2">
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
	on:click={() => (chatOpen = true)}
	class:small-notification={previewDirect.find((preview) => preview.notified)}
	class:small-notification-group={previewGroup.find((preview) => preview.notified)}
	class="dark:text-white transition-all fixed z-30 bg-white dark:bg-darkobject shadow-md border p-6 bottom-6 ml-6 rounded-full cursor-pointer hover:shadow-xl hover:border-gray-400 active:shadow-2xl active:p-7"
>
	<Fa icon={faComment} size="1.3x" />
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

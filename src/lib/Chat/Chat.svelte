<script lang="ts">
	import ChatWindow from './ChatWindow.svelte';
	import Preview from './Preview.svelte';
	import { onMount } from 'svelte';
	// @ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { setTimeStamp, type Message } from './interfaces';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faComment } from '@fortawesome/free-solid-svg-icons/faComment';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Unsubscriber } from 'svelte/store';
	import type { User } from '$lib/User/interfaces';
	import { _ } from 'svelte-i18n';

	// User Action variables
	let messages: Message[] = [],
		chatOpen = true,
		user: User,
		// Specifies which chat window is open
		selectedPage: 'direct' | 'group' = 'direct',
		selectedChat: number,
		//Websocket utility functions and variables
		socket: WebSocket,
		sendMessageToSocket: (
			message: string,
			selectedChat: number,
			selectedPage: 'direct' | 'group'
		) => void,
		unsubscribe: Unsubscriber,
		//Chat history
		olderMessages: string,
		newerMessagesAPI: string,
		displayNotificationDirect = false,
		displayNotificationGroup = false,
		previewDirect: any[] = [],
		previewGroup: any[] = [];

	onMount(async () => {
		await getUser();
		await setUpMessageSending();
	});

	const getUser = async () => {
		const { json, res } = await fetchRequest('GET', 'user');
		user = json;
	};

	const setUpMessageSending = async () => {
		//Must be imported here to avoid "document not found" error
		const { createSocket, subscribe, sendMessage } = (await import('./Socket')).default;
		socket = createSocket(user.id);

		sendMessageToSocket = await sendMessage(socket);

		//This function triggers every time a message arrives from the socket
		//Bug: This happends even when switching chats
		unsubscribe = subscribe(getMessage);
	};

	//There's one large socket that handles messages from everywhere, which is why
	//this function which gets messages from the socket is placed here an not in
	//ChatWindow.svelte

	const getMessage = async (e: any) => {
		//Try-catch to prevent error end at JSON string
		try {
			var { message, user } = JSON.parse(e);
		} catch (err) {
			return;
		}

		//Finds the message on the left side of the chat screen and changes it as the new one comes in.
		let previewMessage = (selectedPage === 'direct' ? previewDirect : previewGroup).find(
			(previewMessage) =>
				previewMessage.user_id === user.id ||
				previewMessage.target_id === user.id ||
				selectedPage === 'group'
		);

		if (previewMessage) {
			previewMessage.message = message;
			previewMessage.created_at = new Date().toString();

			if (selectedChat === previewMessage.user_id) {
				previewMessage.timestamp = new Date().toString();
			}

			previewDirect = previewDirect;
		}

		setTimeStamp(selectedChat, selectedPage);

		if (selectedChat !== user.id) return;

		//If most recent messeges are shown, display new message and scroll
		// if (!newerMessages) {
		messages = [...messages, { message, user, created_at: new Date().toString() }];
	};
</script>

{#if chatOpen}
	<div class="bg-white fixed z-40 w-full grid grid-width-fix">
		<div class="col-start-2 col-end-3 flex justify-between bg-white border border-gray-300 p-2 ">
			<div class="text-xl font-light text-gray-500">{$_('Chat')}</div>
			<div class="cursor-pointer" on:click={() => (chatOpen = false)}>
				<Fa size="1.5x" icon={faX} />
			</div>
		</div>
		<Preview bind:selectedChat bind:selectedPage bind:previewDirect bind:previewGroup {user} />
		<ChatWindow bind:selectedChat bind:selectedPage bind:sendMessageToSocket {user} bind:messages />
	</div>
{:else}
	<div
		on:click={() => (chatOpen = true)}
		class:small-notification={displayNotificationDirect}
		class:small-notification-group={displayNotificationGroup}
		class="transition-all fixed z-30 bg-white shadow-md border p-9 bottom-6 ml-6 rounded-full cursor-pointer hover:shadow-xl hover:border-gray-400 active:shadow-2xl active:p-11"
	>
		<Fa icon={faComment} />
	</div>
{/if}

<!-- <ButtonPrimary action={() => {
	fetchRequest('GET', 'notification')
	// fetchRequest('POST', 'kanban/subscribe', {kanban:2})
	fetchRequest('POST', 'group/2/subscribe', {categories:['poll']})
	// fetchRequest('GET', 'chat/group/preview')
	// fetchRequest('POST', 'group/2/poll/28/subscribe', {categories:['timeline', 'poll']})
	// fetchRequest('POST', 'chat/group/2/timestamp', {
	// 	timestamp :new Date()
	// })
}}
/> -->

<!-- // $: selectedPage === 'direct'
// 	? (displayNotificationDirect = Boolean(notified.length > 0))
// 	: (displayNotificationGroup = Boolean(notified.length > 0));

// ? (displayNotificationDirect = Boolean(notified.length > 0))

// onMount(async () => {
// 	getPreview();

// fetchRequest('GET', 'notification')
// 	fetchRequest('POST', 'notification/subscriptions')
// 	fetchRequest('POST', 'notification/read')
// 	fetchRequest('POST', 'group/2/subscribe', {categories:['group']})

// 	// fetchRequest('POST', 'chat/direct/2/timestamp', {
// }); -->
<style>
	.grid-width-fix {
		grid-template-columns: 30% 70%;
		grid-template-rows: 3rem 50vh 50vh;
	}

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

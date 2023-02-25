<script lang="ts">
	import ChatWindow from './ChatWindow.svelte';
	import Preview from './Preview.svelte';
	import { onMount } from 'svelte';
	// @ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Message, PreviewMessage } from './interfaces';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faComment } from '@fortawesome/free-solid-svg-icons/faComment';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { User } from '$lib/User/interfaces';
	import { _ } from 'svelte-i18n';
	import CrossButton from '$lib/Generic/CrossButton.svelte';

	let messages: Message[] = [],
		chatOpen = import.meta.env.VITE_MODE === 'DEV' ? false : false,
		User: User,
		// Specifies which chat window is open
		selectedPage: 'direct' | 'group' = 'direct',
		selectedChat: number | null,
		//Websocket utility functions and variables
		socket: WebSocket,
		sendMessageToSocket: (
			message: string,
			selectedChat: number,
			selectedPage: 'direct' | 'group'
		) => void,
		//The preview page on the left side of the chat screen
		previewDirect: PreviewMessage[] = [],
		previewGroup: PreviewMessage[] = [],
		notifiedDirect: number[] = [],
		notifiedGroup: number[] = [],
		isLookingAtOlderMessages = false;

	onMount(async () => {
		await getUser();
		await setUpMessageSending();
	});

	const getUser = async () => {
		const { json, res } = await fetchRequest('GET', 'user');
		if (res.ok) User = json;
	};

	const setUpMessageSending = async () => {
		//Must be imported here to avoid "document not found" error
		const { createSocket, subscribe, sendMessage } = (await import('./Socket')).default;
		socket = createSocket(User.id);

		sendMessageToSocket = await sendMessage(socket);

		subscribe(getMessage);
	};

	//There's one large socket that handles messages from everywhere, which is why
	//this function which gets messages from the socket is placed here an not in
	//ChatWindow.svelte

	const getMessage = async (e: any) => {
		//Try-catch to prevent error end at JSON string
		try {
			var { message, user, group, target_type } = JSON.parse(e);
		} catch (err) {
			return;
		}

		if (isLookingAtOlderMessages) return;

		//Finds the message on the left side of the chat screen and changes it as the new one comes in.
		let previewMessage = (target_type === 'direct' ? previewDirect : previewGroup).find(
			(previewMessage) =>
				(target_type === 'direct' &&
					(previewMessage.user_id === user.id || previewMessage.target_id === user.id)) ||
				(target_type === 'group' && previewMessage.group_id === group)
		);

		if (previewMessage) {
			previewMessage.message = message;
			previewMessage.created_at = new Date().toString();

			if (selectedChat === previewMessage.user_id) {
				previewMessage.timestamp = new Date().toString();
			}
		} else {
			//For brand new chats, create new preview message
			(target_type === 'direct' ? previewDirect : previewGroup).push({
				created_at: new Date().toString(),
				message,
				timestamp: new Date().toString(),
				username: user.username,
				user_id: user.id,
				target_id: User.id,
				target_username: User.username,
				profile_image: '',
				group_id: group
			});
		}

		previewGroup = previewGroup;
		previewDirect = previewDirect;

		if (
			(selectedPage === 'direct' && target_type === 'direct' && user && user.id === selectedChat) ||
			(selectedPage === 'group' && target_type === 'group' && group === selectedChat)
		)
			messages = [...messages, { message, user, created_at: new Date().toString() }];
	};

	//White screen when changing between direct and groups
	$: selectedPage &&
		(() => {
			// selectedChat = null;
		})();

	$: if (chatOpen === false) {
		// selectedChat = null;
		// selectedPage === 'direct';
	}
</script>

<svelte:head
	><title 
		>{`${notifiedDirect.length > 0 ? '🟣' : ''}${
			notifiedGroup.length > 0 ? '🔵' : ''
		} Flowback`}</title
	></svelte:head
>
<div class:invisible={!chatOpen} class="bg-white fixed z-40 w-full grid grid-width-fix">
	<div class="col-start-2 col-end-3 flex justify-between bg-white border border-gray-300 p-2 ">
		<div class="text-xl font-light text-gray-500">{$_('Chat')}</div>
		<div class="cursor-pointer" on:click={() => (chatOpen = false)}>
			<CrossButton  />
		</div>
	</div>
	<Preview
		bind:selectedChat
		bind:selectedPage
		bind:previewDirect
		bind:previewGroup
		bind:notifiedDirect
		bind:notifiedGroup
	/>
	<ChatWindow
		bind:previewDirect
		bind:previewGroup
		bind:selectedChat
		bind:selectedPage
		bind:sendMessageToSocket
		user={User}
		bind:messages
		bind:isLookingAtOlderMessages
	/>
</div>
<div
	on:click={() => (chatOpen = true)}
	class:small-notification={notifiedDirect.length > 0}
	class:small-notification-group={notifiedGroup.length > 0}
	class="transition-all fixed z-30 bg-white shadow-md border p-6 bottom-6 ml-6 rounded-full cursor-pointer hover:shadow-xl hover:border-gray-400 active:shadow-2xl active:p-7"
>
	<Fa icon={faComment} size="1.3x" />
</div>

<style>
	.grid-width-fix {
		grid-template-columns: 30% 70%;
		grid-template-rows: 2.9rem 58vh 28vh;
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

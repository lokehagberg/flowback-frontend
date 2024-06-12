<script lang="ts">
	// @ts-ignore
	import { type Message, type Message1, type PreviewMessage } from './interfaces';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { User } from '$lib/User/interfaces';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import { _ } from 'svelte-i18n';
	import { browser } from '$app/environment';
	import TextArea from '$lib/Generic/TextArea.svelte';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faPaperPlane } from '@fortawesome/free-solid-svg-icons/faPaperPlane';
	import { faSmile } from '@fortawesome/free-solid-svg-icons/faSmile';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import sendMessage, { messageStore } from './Socket';
	import { onMount } from 'svelte';
	import Socket from './Socket';
	import { updateUserData } from './functions';
	import { writable } from 'svelte/store';

	// User Action variables
	let message: string = import.meta.env.VITE_MODE === 'DEV' ? 'a' : '',
		olderMessages: string,
		newerMessages: string,
		showEmoji = false,
		status: {
			message: any;
			success: boolean;
		},
		messages: Message[] = [],
		socket: WebSocket;

	export let selectedChat: number | null,
		// sendMessage: (
		// 	socket: WebSocket,
		// 	channel_id: number,
		// 	message: string,
		// 	topic_id: number,
		// 	attachments_id?: number | null,
		// 	parent_id?: number | null
		// ) => Promise<boolean>,

		user: User,
		selectedPage: 'direct' | 'group',
		previewDirect: PreviewMessage[] = [],
		previewGroup: PreviewMessage[] = [],
		isLookingAtOlderMessages: boolean;

	onMount(() => {

		const a = writable("a")
		setTimeout(() => {
			a.set("HOWDY")
		})
		a.subscribe(msg => {
			console.log(msg)
		})

		recieveMessage();
	});

	const getRecentMesseges = async () => {
		if (!selectedChat) return;

		const { res, json } = await fetchRequest(
			'GET',
			`chat/message/channel/${selectedChat}/list?order_by=created_at_desc&limit=${25}`
		);

		if (res.ok) messages = json.results.reverse();

		//Temporary fix before json.next issue is fixed
		olderMessages = json.next;
		newerMessages = '';
	};

	const getChannelId = async (id: number) => {
		const { res, json } = await fetchRequest('GET', `user/chat/${id}`);
		return json;
	};

	//Runs when changing chats
	const postMessage = async () => {
		if (!selectedChat) return;
		if (message.length === 0) return;
		//If only spaces, return
		if (message.match(/^\s+$/)) return;

		//When sending, go to most recent messages
		if (newerMessages) getRecentMesseges();

		//Updates preview window to display recently typed chat message
		let previewMessage = (selectedPage === 'group' ? previewGroup : previewDirect).find(
			(previewMessage) =>
				(selectedPage === 'direct' &&
					((previewMessage.user_id === user.id && previewMessage.target_id === selectedChat) ||
						(previewMessage.target_id === user.id && previewMessage.user_id === selectedChat))) ||
				(selectedPage === 'group' && previewMessage.group_id === selectedChat)
		);
		if (previewMessage) {
			previewMessage.message = message;
			previewMessage.created_at = new Date().toString();
		}
		// else {
		// 	//For brand new chats, create new preview message
		// 	(selectedPage === 'direct' ? previewDirect : previewGroup).push({
		// 		id: 1,
		// 		created_at: new Date().toString(),
		// 		message,
		// 		timestamp: new Date().toString(),
		// 		username: user.username,
		// 		user_id: user.id,
		// 		notified: false,
		// 		// target_id: selectedPage === 'direct' ? selectedChat : 0,
		// 		target_username: user.username,
		// 		profile_image: ''
		// 		// group_id: selectedPage === 'group' ? selectedChat : 0
		// 	});
		// }

		selectedPage === 'direct' ? (previewDirect = previewDirect) : (previewGroup = previewGroup);

		let channelId = selectedChat;
		if (selectedPage === 'direct') channelId = (await getChannelId(selectedChat)).id;

		const didSend = await sendMessage.sendMessage(socket, channelId, message, 1);

		if (!didSend) status = { message: 'Could not send message', success: false };
		else
			messages.push({
				message,
				user: { username: user.username, id: user.id, profile_image: user.profile_image || '' },
				created_at: new Date().toString()
			});

		messages = messages;
		message = import.meta.env.VITE_MODE === 'DEV' ? message + 'a' : '';

		updateUserData(selectedChat, new Date());
	};

	const showOlderMessages = async () => {
		const { res, json } = await fetchRequest('GET', olderMessages);

		if (!res.ok) return;
		newerMessages = json.previous;
		olderMessages = json.next;

		messages = json.results.reverse();
	};

	const showEarlierMessages = async () => {
		const { res, json } = await fetchRequest('GET', newerMessages);

		olderMessages = json.next;
		newerMessages = json.previous;

		messages = json.results.reverse();
	};

	//Uses svelte stores to recieve messages
	const recieveMessage = () => {
		messageStore.subscribe((message: Message1) => {
			if (!message) return;

			if (message.channel_origin_name === 'group') {
				handleRecieveMessage(previewGroup, message);
				previewGroup = previewGroup;
			} else if (message.channel_origin_name === 'user') {
				handleRecieveMessage(previewDirect, message);
				previewDirect = previewDirect;
			}
		});
	};

	const handleRecieveMessage = (preview: PreviewMessage[], message: Message1) => {
		if (message.channel_id !== selectedChat) {
			let notifiedChannel = preview.find((info) => {
				return info.channel_id === message.channel_id;
			});

			// If no channel has started yet, start it. New chats will work like this
			if (!notifiedChannel) {
				preview.push({
					created_at: message.created_at.toString(),
					id: message.id,
					message: message.message,
					notified: true,
					profile_image: message.user.profile_image,
					timestamp: new Date().toString(),
					user: message.user,
					user_id: message.user.id,
					channel_id: message.channel_id
				});
				preview = preview;
			} else {
				notifiedChannel.notified = true;
				notifiedChannel.message = message.message
				preview = preview;
			}
		} else if (message.channel_id === selectedChat) {
			messages.push({
				message: message.message,
				user: {
					id: message.id,
					username: message.user.username,
					profile_image: message.user.profile_image
				}
			});
			messages = messages;
		}
	};

	$: (selectedPage || selectedChat) && getRecentMesseges();

	$: {
		if (newerMessages) isLookingAtOlderMessages = true;
		else isLookingAtOlderMessages = false;
	}

	//When messages are recieved and not looking at history, scroll.
	$: messages &&
		(async () => {
			if (newerMessages) return;
			if (!browser) return;

			await setTimeout(() => {
				const d = document.querySelector('#chat-window');
				d?.scroll(0, 100000);
			}, 100);
		})();

	$: if (user) socket = Socket.createSocket(user.id);
</script>

{#if selectedChat !== null || true}
	<ul
		class="dark:bg-darkobject col-start-2 col-end-3 bg-white h-[100%] overflow-y-scroll overflow-x-hidden break-all"
		id="chat-window"
	>
		{#if messages.length === 0}
			<span class="self-center">{'Chat is currently empty, maybe say hello?'}</span>
		{/if}
		{#if olderMessages}
			<li class="text-center mt-6 mb-6">
				<Button action={showOlderMessages}>{$_('Show older messages')}</Button>
			</li>
		{/if}
		<!-- <div class="absolute bottom-0 right-0">{$_("New messages")}</div> -->
		{#each messages as message}
			<li class="p-3 hover:bg-gray-200 hover:dark:bg-darkbackground">
				<span>{message.user?.username || message.username}</span>
				<span class="text-[14px] text-gray-400 ml-3">{formatDate(message.created_at)}</span>
				<p>{message.message}</p>
			</li>
		{/each}
		{#if newerMessages}
			<li class="text-center mt-6 mb-6">
				<Button action={showEarlierMessages} buttonStyle="secondary"
					>{$_('Show earlier messages')}</Button
				>
			</li>
		{/if}
		<StatusMessage bind:status disableSuccess />
	</ul>
	<!-- <div class:invisible={!showEmoji} class="fixed">
	</div> -->
	<div class="dark:bg-darkobject col-start-2 col-end-3 bg-white shadow rounded p-2 w-full">
		<!-- Here the user writes a message to be sent -->
		<form
			class="w-full flex gap-2 md:mt-2 lg:mt-5 xl:mt-14 items-center"
			on:submit|preventDefault={postMessage}
		>
			<TextArea
				autofocus
				label=""
				onKeyPress={(e) => {
					if (e.key === 'Enter' && !e.shiftKey) {
						postMessage();
						e.preventDefault();
					}
				}}
				required
				max={3000}
				bind:value={message}
				Class="w-full"
			/>

			{#if import.meta.env.VITE_MODE === 'DEV'}
				<Button
					action={() => (showEmoji = !showEmoji)}
					Class="rounded-full pl-3 pr-3 pt-3 pb-3 h-1/2"><Fa icon={faSmile} /></Button
				>
			{/if}

			<Button type="submit" Class="rounded-full pl-3 pr-3 pt-3 pb-3 h-1/2"
				><Fa icon={faPaperPlane} /></Button
			>
		</form>
	</div>
{:else}
	<div>{'No chat selected'}</div>
{/if}


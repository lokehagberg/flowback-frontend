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
	import { chatWindow as chatWindowLimit } from '../Generic/APILimits.json';
	import { env } from '$env/dynamic/public';

	// User Action variables
	let message: string = env.PUBLIC_MODE === 'DEV' ? 'a' : '',
		olderMessages: string,
		newerMessages: string,
		showEmoji = false,
		status: {
			message: any;
			success: boolean;
		},
		messages: Message[] = [],
		socket: WebSocket,
		chatWindow: any;

	export let selectedChat: number | null,
		selectedChatChannelId: number | null,
		user: User,
		selectedPage: 'direct' | 'group',
		previewDirect: PreviewMessage[] = [],
		previewGroup: PreviewMessage[] = [],
		isLookingAtOlderMessages: boolean;

	const getRecentMesseges = async () => {
		if (!selectedChatChannelId) return;

		const { res, json } = await fetchRequest(
			'GET',
			`chat/message/channel/${selectedChatChannelId}/list?order_by=created_at_desc&limit=${chatWindowLimit}`
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

		selectedPage === 'direct' ? (previewDirect = previewDirect) : (previewGroup = previewGroup);

		let channelId = selectedChat;
		if (selectedPage === 'direct') channelId = (await getChannelId(selectedChat)).id;

		if (!channelId) return;

		if (!selectedChatChannelId) return;

		const didSend = await sendMessage.sendMessage(socket, selectedChatChannelId, message, 1);
		if (!didSend) status = { message: 'Could not send message', success: false };
		else
			messages.push({
				message,
				user: { username: user.username, id: user.id, profile_image: user.profile_image || '' },
				created_at: new Date().toString()
			});

		messages = messages;
		message = env.PUBLIC_MODE === 'DEV' ? message + 'a' : '';

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
				notifiedChannel.message = message.message;
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

	const correctHeightRelativeToHeader = () => {
		const headerHeight = document.querySelector('#header')?.clientHeight;
		if (headerHeight && chatWindow)
			chatWindow.style.height = `calc(100% - ${headerHeight.toString()}px)`;
	};

	onMount(() => {
		recieveMessage();
		correctHeightRelativeToHeader();
		window.addEventListener('resize', correctHeightRelativeToHeader);
	});

	//Whenever user has switched chat, show messages in the new chat
	$: (selectedPage || selectedChat) && getRecentMesseges();

	//Behavior is differnet when looking at older chat messages
	$: {
		if (newerMessages) isLookingAtOlderMessages = true;
		else isLookingAtOlderMessages = false;
	}

	//When messages are recieved and not looking at history, scroll to bottom.
	//TODO: Question if we need this, discord doesn't have this feature and I like that.
	$: messages &&
		(async () => {
			if (newerMessages) return;
			if (!browser) return;

			await setTimeout(() => {
				const d = document.querySelector('#chat-window');
				d?.scroll(0, 100000);
			}, 100);
		})();

	$: {
		if (newerMessages) isLookingAtOlderMessages = true;
		else isLookingAtOlderMessages = false;
	}
</script>

{#if selectedChat !== null || true}
	<ul
		class="col-start-2 col-end-3 overflow-y-scroll overflow-x-hidden break-all"
		id="chat-window"
		bind:this={chatWindow}
	>
		{#if messages.length === 0}
			<span class="self-center">{'Chat is currently empty, maybe say hello?'}</span>
		{/if}
		{#if olderMessages}
			<li class="text-center mt-6 mb-6">
				<Button action={showOlderMessages}>{$_('Show older messages')}</Button>
			</li>
		{/if}

		{#each messages as message}
			{@const sentByUser = message.user.id.toString() === localStorage.getItem('userId') || false}
			<li class="px-4 py-2 max-w-[80%]" class:ml-auto={sentByUser}>
				<span>{message.user?.username || message.username}</span>
				<p
					class="p-2 rounded-xl"
					class:bg-primary={sentByUser}
					class:dark:bg-gray-600={sentByUser}
					class:text-white={sentByUser}
					class:bg-gray-300={!sentByUser}
					class:dark:bg-gray-500={!sentByUser}
				>
					{message.message}
				</p>
				<span class="text-[14px]text-gray-400 ml-3">{formatDate(message.created_at)}</span>
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
	<div class="shadow rounded">
		<!-- Here the user writes a message to be sent -->
		<form class="flex gap-1 items-center" on:submit|preventDefault={postMessage}>
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

			{#if env.PUBLIC_MODE === 'DEV'}
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

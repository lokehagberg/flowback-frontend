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
	import Fa from 'svelte-fa';
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
		chatWindow: any,
		errorState = false;

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

		if (!res.ok) {
			selectedChat = null;
			messages = [];
			errorState = true;
			return;
		}

		messages = json.results.reverse();

		//Temporary fix before json.next issue is fixed
		//TODO: Fix it
		olderMessages = json.next;
		newerMessages = '';
	};

	const getChannelId = async (id: number) => {
		const { res, json } = await fetchRequest('GET', `user/chat?target_user_ids=${id}`);
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
		if (selectedPage === 'direct') channelId = selectedChat;

		if (!channelId) return;

		if (!selectedChatChannelId) return;

		const didSend = await sendMessage.sendMessage(socket, selectedChatChannelId, message, 1);

		if (!didSend) status = { message: 'Could not send message', success: false };
		else
			messages.push({
				id: Date.now(),
				message,
				user: { username: user.username, id: user.id, profile_image: user.profile_image || '' },
				created_at: new Date().toString(),
				active: true,
				channel_id: selectedChatChannelId || selectedChat,
				channel_origin_name: selectedPage === 'direct' ? 'user' : 'group',
				type: 'message',
				updated_at: new Date().toString(),
				attachments: [],
				channel_title: '',
				parent: 0,
				topic_id: 0
			});

		messages = messages;
		message = env.PUBLIC_MODE === 'DEV' ? message + 'a' : '';

		updateUserData(selectedChat, new Date());
	};

	const showOlderMessages = async () => {
		console.log(olderMessages, 'NEEEXY');
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
			//@ts-ignore
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

	//Behavior is different when looking at older chat messages
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

	//@ts-ignore
	$: if (user) socket = Socket.createSocket(user.id);
</script>

{#if selectedChat !== null || true}
	<div class="flex flex-col h-full">
		<ul class="grow overflow-y-auto px-2 break-all" id="chat-window" bind:this={chatWindow}>
			{#if messages.length === 0 && selectedChat !== undefined && selectedChat !== 0 && selectedChat !== null}
				<span class="self-center">{$_('Chat is currently empty, maybe say hello?')}</span>
			{:else if selectedChat === undefined || selectedChat === null}
				<span class="self-center">{$_('')}</span>
			{/if}
			{#if olderMessages}
				<li class="text-center mt-6 mb-6">
					<Button onClick={showOlderMessages}>{$_('Show older messages')}</Button>
				</li>
			{/if}

			{#each messages as message}
				{#if message.type === 'info'}
					<li class="px-4 py-2 max-w-[80%] text-center">
						{message.message}
					</li>
				{:else}
					{@const sentByUser =
						message.user.id.toString() === localStorage.getItem('userId') || false}
					<li class="px-4 py-2 max-w-[80%]" class:ml-auto={sentByUser}>
						<span>{message.user?.username}</span>
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
				{/if}
			{/each}
			{#if newerMessages}
				<li class="text-center mt-6 mb-6">
					<Button onClick={showEarlierMessages} buttonStyle="secondary"
						>{$_('Show earlier messages')}</Button
					>
				</li>
			{/if}
			<StatusMessage bind:status disableSuccess />
		</ul>
		<!-- <div class:invisible={!showEmoji} class="fixed">
	</div> -->
		{#if selectedChat !== 0 && selectedChat !== undefined && selectedChat !== null}
			<div class="border-t-2 border-t-gray-200 w-full">
				<!-- Here the user writes a message to be sent -->
				<form
					class="flex gap-1 justify-center items-center w-full mt-2"
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
						max={3000}
						rows={1}
						bind:value={message}
						placeholder={$_('Write a message...')}
						Class="justify-center w-full h-2rem"
						inputClass="border-0 bg-gray-100 placeholder-gray-700 pl-2 pt-1 resize-y min-h-[2rem] max-h-[6rem] overflow-auto"
					/>

					{#if env.PUBLIC_MODE === 'DEV'}
						<Button
							onClick={() => (showEmoji = !showEmoji)}
							Class="rounded-full pl-3 pr-3 pt-3 pb-3 h-1/2"><Fa icon={faSmile} /></Button
						>
					{/if}

					<Button
						type="submit"
						Class="bg-transparent border-none flex items-center justify-center p-3 h-1/2"
						><Fa class="text-blue-600 text-lg" icon={faPaperPlane} /></Button
					>
				</form>
			</div>
		{/if}
	</div>
{:else}
	<div>{'No chat selected'}</div>
{/if}

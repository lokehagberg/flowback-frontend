<script lang="ts">
	import { type Message, type Message1, type PreviewMessage } from './interfaces';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { User } from '$lib/User/interfaces';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import { _ } from 'svelte-i18n';
	import { browser } from '$app/environment';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Fa from 'svelte-fa';
	import { faPaperPlane, faSmile } from '@fortawesome/free-solid-svg-icons';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import { messageStore } from './Socket';
	import { onMount, onDestroy } from 'svelte';
	import Socket from './Socket';
	import { updateUserData } from './functions';
	import { chatWindow as chatWindowLimit } from '../Generic/APILimits.json';
	import { env } from '$env/dynamic/public';
	import Modal from '$lib/Generic/Modal.svelte';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';

	export let selectedChat: number | null,
		selectedChatChannelId: number | null,
		user: User,
		selectedPage: 'direct' | 'group',
		previewDirect: PreviewMessage[] = [],
		previewGroup: PreviewMessage[] = [],
		isLookingAtOlderMessages: boolean;

	let message: string = env.PUBLIC_MODE === 'DEV' ? 'a' : '',
		olderMessages: string,
		newerMessages: string,
		showEmoji = false,
		status: { message: any; success: boolean },
		messages: Message[] = [],
		socket: WebSocket,
		chatWindow: any,
		errorState = false,
		participants: any[] = [],
		participantsModalOpen = false;

	// Fetch recent messages for the selected chat
	const getRecentMessages = async () => {
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
		olderMessages = json.next;
		newerMessages = '';
		// Update timestamp when viewing messages
		const timestampKey = `lastInteraction_${selectedChatChannelId}`;
		localStorage.setItem(timestampKey, new Date().toISOString());

		// console.log("getRecentMessages timestampKey", timestampKey, localStorage.getItem(timestampKey));
		// console.log(`Loaded messages for ${selectedPage} chat (channel ${selectedChatChannelId}):`, messages);
	};

	// Send a message and update localStorage timestamp
	const postMessage = async () => {
		if (!selectedChat || !selectedChatChannelId || message.length === 0 || message.match(/^\s+$/)) return;

		if (newerMessages) await getRecentMessages();

		let previewMessage = (selectedPage === 'group' ? previewGroup : previewDirect).find(
			(p) =>
				(selectedPage === 'direct' &&
					((p.user_id === user.id && p.target_id === selectedChat) ||
						(p.target_id === user.id && p.user_id === selectedChat))) ||
				(selectedPage === 'group' && p.group_id === selectedChat)
		);
		if (previewMessage) {
			previewMessage.message = message;
			previewMessage.created_at = new Date().toString();
			previewMessage.notified = false;
		} else {
			previewMessage = {
				id: Date.now(),
				message,
				created_at: new Date().toString(),
				timestamp: new Date().toString(),
				notified: false,
				profile_image: user.profile_image || '',
				user_id: user.id,
				user: { id: user.id, username: user.username, profile_image: user.profile_image, banner_image: '' },
				channel_id: selectedChatChannelId,
				...(selectedPage === 'direct' ? { target_id: selectedChat } : { group_id: selectedChat })
			};
			if (selectedPage === 'group') previewGroup.push(previewMessage);
			else previewDirect.push(previewMessage);
		}

		previewDirect = previewDirect;
		previewGroup = previewGroup;

		const didSend = await Socket.sendMessage(socket, selectedChatChannelId, message, 1);
		if (!didSend) {
			status = { message: 'Could not send message', success: false };
			return;
		}

		messages.push({
			id: Date.now(),
			message,
			user: { username: user.username, id: user.id, profile_image: user.profile_image || '' },
			created_at: new Date().toString(),
			active: true,
			channel_id: selectedChatChannelId,
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

		// Update localStorage timestamp when sending a message
		const timestampKey = `lastInteraction_${selectedChat}`;
		localStorage.setItem(timestampKey, new Date().toISOString());

		await updateUserData(selectedChat, new Date());
	};

	// Fetch older messages
	const showOlderMessages = async () => {
		if (!olderMessages) return;
		const { res, json } = await fetchRequest('GET', olderMessages);
		if (!res.ok) return;
		newerMessages = json.previous;
		olderMessages = json.next;
		messages = json.results.reverse();
	};

	// Fetch newer messages
	const showEarlierMessages = async () => {
		if (!newerMessages) return;
		const { res, json } = await fetchRequest('GET', newerMessages);
		olderMessages = json.next;
		newerMessages = json.previous;
		messages = json.results.reverse();
	};

	// Handle incoming messages and set notifications
	const handleReceiveMessage = (preview: PreviewMessage[], message: Message1) => {	
		if (message.channel_id === selectedChatChannelId) {
			if (messages.some((m) => m.id === message.id)) return;

			messages.push({
				id: message.id,
				message: message.message,
				user: {
					id: message.user.id,
					username: message.user.username,
					profile_image: message.user.profile_image
				},
				created_at: message.created_at.toString(),
				active: true,
				channel_id: message.channel_id,
				channel_origin_name: message.channel_origin_name,
				type: message.type,
				updated_at: message.updated_at.toString(),
				attachments: [],
				channel_title: '',
				parent: message.parent,
				topic_id: message.topic_id
			});
			messages = messages;
			updateUserData(selectedChatChannelId, new Date());
		} else {
			let previewMessage = preview.find((p) => p.channel_id === message.channel_id);
			if (!previewMessage) {
				previewMessage = {
					id: message.id,
					message: message.message,
					created_at: message.created_at.toString(),
					timestamp: new Date().toString(),
					notified: true,
					profile_image: message.user.profile_image,
					user_id: message.user.id,
					user: message.user,
					channel_id: message.channel_id,
					...(message.channel_origin_name === 'group' ? { group_id: message.channel_id } : { target_id: message.user.id })
				};
				preview.push(previewMessage);
			} else {
				previewMessage.message = message.message;
				previewMessage.created_at = message.created_at.toString();
				previewMessage.notified = true;
			}
			preview = [...preview];
		}
	};

	// Subscribe to incoming messages
	const receiveMessage = () => {
		const unsubscribe = messageStore.subscribe((message: Message1) => {
			if (!message || message.user.id === user.id) return;
			if (message.channel_origin_name === 'group') {
				handleReceiveMessage(previewGroup, message);
				previewGroup = previewGroup;
			} else if (message.channel_origin_name === 'user') {
				handleReceiveMessage(previewDirect, message);
				previewDirect = previewDirect;
			}
		});
		return unsubscribe;
	};

	// Adjust chat window height based on header
	const correctHeightRelativeToHeader = () => {
		const headerHeight = document.querySelector('#header')?.clientHeight;
		if (headerHeight && chatWindow)
			chatWindow.style.height = `calc(100% - ${headerHeight.toString()}px)`;
	};

	// Fetch channel participants
	const getChannelParticipants = async () => {
		if (!selectedChatChannelId) return;
		const { res, json } = await fetchRequest(
			'GET',
			`chat/message/channel/${selectedChatChannelId}/participant/list`
		);
		if (!res.ok) {
			console.error('Failed to fetch channel participants:', json);
			return;
		}
		participants = json.results;
		// console.log(`Participants for ${selectedPage} chat (channel ${selectedChatChannelId}):`, participants);
	};

	let unsubscribeMessageStore: () => void;

	onMount(() => {
		unsubscribeMessageStore = receiveMessage();
		correctHeightRelativeToHeader();
		window.addEventListener('resize', correctHeightRelativeToHeader);
	});

	onDestroy(() => {
		if (unsubscribeMessageStore) unsubscribeMessageStore();
		window.removeEventListener('resize', correctHeightRelativeToHeader);
	});

	// Reactive updates
	$: (selectedPage || selectedChatChannelId) && getRecentMessages();
	$: (selectedPage || selectedChatChannelId) && getChannelParticipants();
	$: isLookingAtOlderMessages = !!newerMessages;
	$: if (user) socket = Socket.createSocket(user.id);
	$: messages &&
		browser &&
		setTimeout(() => {
			if (newerMessages) return;
			const d = document.querySelector('#chat-window');
			d?.scroll(0, 100000);
		}, 100);
	$: if (selectedChatChannelId) {
		updateUserData(selectedChatChannelId, new Date());
	}
</script>

{#if selectedChatChannelId !== null}
	<div class="flex flex-col h-full">
		<ul class="grow overflow-y-auto px-2 break-all" id="chat-window" bind:this={chatWindow}>
			{#if messages.length === 0 && selectedChatChannelId}
				<span class="self-center">{$_('Chat is currently empty, maybe say hello?')}</span>
			{/if}
			{#if olderMessages}
				<li class="text-center mt-6 mb-6">
					<Button onClick={showOlderMessages}>{$_('Show older messages')}</Button>
				</li>
			{/if}
			{#each messages as message (message.id)}
				{#if message.type === 'info'}
					<li class="px-4 py-2 max-w-[80%] text-center">{message.message}</li>
				{:else}
					{@const sentByUser = message.user.id.toString() === localStorage.getItem('userId')}
					<li class="px-4 py-2 max-w-[80%]" class:ml-auto={sentByUser}>
						<span>{message.user?.username}</span>
						<p
							class="p-2 rounded-xl"
							class:bg-primary={sentByUser}
							class:text-white={sentByUser}
							class:bg-gray-300={!sentByUser}
							class:dark:bg-gray-600={sentByUser}
							class:dark:bg-gray-500={!sentByUser}
						>
							{message.message}
						</p>
						<span class="text-[14px] text-gray-400 ml-3">
							{formatDate(message.created_at || new Date())}
						</span>
					</li>
				{/if}
			{/each}
			{#if newerMessages}
				<li class="text-center mt-6 mb-6">
					<Button onClick={showEarlierMessages} buttonStyle="secondary">
						{$_('Show earlier messages')}
					</Button>
				</li>
			{/if}
			<StatusMessage bind:status disableSuccess />
		</ul>
		{#if selectedChatChannelId}
			<div class="border-t-2 border-t-gray-200 w-full">
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
							Class="rounded-full pl-3 pr-3 pt-3 pb-3 h-1/2"
						>
							<Fa icon={faSmile} />
						</Button>
					{/if}
					<Button
						type="submit"
						Class="bg-transparent border-none flex items-center justify-center p-3 h-1/2"
					>
						<Fa class="text-blue-600 text-lg" icon={faPaperPlane} />
					</Button>
				</form>
			</div>
		{/if}
	</div>
	<Button onClick={() => (participantsModalOpen = true)}>Show users</Button>
{:else}
	<div>{'No chat selected'}</div>
{/if}

<Modal bind:open={participantsModalOpen}>
	<div slot="body">
		{#if participants.length > 0}
			<ul>
				{#each participants as participant (participant.id)}
					<ProfilePicture
						displayName
						username={participant.user.username}
						profilePicture={participant.user.profile_image}
					/>
				{/each}
			</ul>
		{:else}
			<p>No participants found.</p>
		{/if}
	</div>
</Modal>
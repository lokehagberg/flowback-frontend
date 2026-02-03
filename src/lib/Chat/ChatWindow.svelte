<script lang="ts">
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import { type Message, type Message1, type PreviewMessage } from './interfaces';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { userStore } from '$lib/User/interfaces';
	import { _ } from 'svelte-i18n';
	import { browser } from '$app/environment';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Fa from 'svelte-fa';
	import { faPaperPlane, faUsers } from '@fortawesome/free-solid-svg-icons';
	import { messageStore } from './Socket';
	import { onMount, onDestroy } from 'svelte';
	import Socket from './Socket';
	import { chatWindow as chatWindowLimit } from '../Generic/APILimits.json';
	import Modal from '$lib/Generic/Modal.svelte';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { chatPartnerStore, previewStore } from './functions';

	export let selectedPage: 'direct' | 'group', isLookingAtOlderMessages: boolean;

	let message: string = '',
		olderMessages: string,
		newerMessages: string,
		showEmoji = false,
		messages: Message[] = [],
		socket: WebSocket | null = null,
		chatWindow: any,
		errorState = false,
		participants: any[] = [],
		participantsModalOpen = false;

	// Fetch recent messages for the selected chat
	const getRecentMessages = async () => {
		if (!$chatPartnerStore) return;
		const { res, json } = await fetchRequest(
			'GET',
			`chat/message/channel/${$chatPartnerStore}/list?order_by=created_at_desc&limit=${chatWindowLimit}`
		);
		if (!res.ok) {
			messages = [];
			$chatPartnerStore = null;
			errorState = true;
			return;
		}
		messages = json?.results.reverse();
		olderMessages = json.next;
		newerMessages = '';
	};

	const postMessage = async () => {
		if (!$chatPartnerStore || message.length === 0 || message.match(/^\s+$/)) return;

		if (newerMessages) await getRecentMessages();

		let previewMessage = $previewStore?.find(
			(p) => p.id === $chatPartnerStore || p.recent_message?.group_id === $chatPartnerStore
		);

		if (previewMessage) {
			// previewMessage.recent_message.message = message;
			// previewMessage.recent_message.created_at = new Date().toString();
			// previewMessage.recent_message.notified = false;
			// previewMessage = previewMessage;
		} else {
			previewMessage = {
				id: Date.now(),
				timestamp: new Date().toString(),
				participants: [],
				recent_message: {
					message,
					created_at: new Date().toString(),
					notified: false,
					profile_image: $userStore?.profile_image || '',
					user_id: $userStore?.id || -1,
					user: {
						id: $userStore?.id || -1,
						username: $userStore?.username || '',
						profile_image: $userStore?.profile_image || '',
						banner_image: ''
					},
					channel_id: $chatPartnerStore,
					...(selectedPage === 'direct'
						? { target_id: $chatPartnerStore }
						: { group_id: $chatPartnerStore })
				}
			};
		}

		const didSend = await Socket.sendMessage(socket, $chatPartnerStore, message, 1);
		if (!didSend) {
			ErrorHandlerStore.set({ message: 'Could not send message', success: false });
			return;
		}

		const preview = $previewStore?.find((p) => p.channel_id === $chatPartnerStore);
		if (preview) {
			// preview.recent_message.message = message;
		}
		messages.push({
			id: Date.now(),
			message,
			user: {
				username: $userStore?.username || '',
				id: $userStore?.id || -1,
				profile_image: $userStore?.profile_image || ''
			},
			created_at: new Date().toString(),
			active: true,
			channel_id: $chatPartnerStore,
			channel_origin_name: 'group',
			type: 'message',
			updated_at: new Date().toString(),
			attachments: [],
			channel_title: '',
			parent: 0,
			topic_id: 0
		});
		messages = messages;

		message = '';
	};

	// Fetch older messages
	const showOlderMessages = async () => {
		if (!olderMessages) return;
		const { res, json } = await fetchRequest('GET', olderMessages);
		if (!res.ok) return;
		newerMessages = json.previous;
		olderMessages = json.next;
		messages = json?.results.reverse();
	};

	// Fetch newer messages
	const showNewerMessages = async () => {
		if (!newerMessages) return;
		const { res, json } = await fetchRequest('GET', newerMessages);
		olderMessages = json.next;
		newerMessages = json.previous;
		messages = json?.results.reverse();
	};

	// Handle incoming messages and set notifications
	const handleReceiveMessage = (preview: PreviewMessage[], message: Message1) => {
		if (message.channel_id === $chatPartnerStore) {
			if (messages.some((m) => m.id === message.id)) return;

			messages.push({
				id: message.id,
				message: message.message,
				user: {
					id: message.user?.id,
					username: message.user?.username,
					profile_image: message.user?.profile_image
				},
				created_at: new Date().toString(),
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
			// updateUserData($chatPartnerStore, new Date());
		} else {
			let previewMessage = preview.find((p) => p.channel_id === message.channel_id);
			if (!previewMessage) {
				// 	previewMessage = {
				// 		id: message.id,
				// 		message: message.message,
				// 		// created_at: message.created_at.toString(),
				// 		timestamp: new Date().toString(),
				// 		notified: true,
				// 		profile_image: message.user?.profile_image,
				// 		user_id: message.user?.id,
				// 		user: message.user,
				// 		channel_id: message.channel_id,
				// 		...(message.channel_origin_name === 'group'
				// 			? { group_id: message.channel_id }
				// 			: { target_id: message.user?.id })
				// 	};
				// 	preview.push(previewMessage);
			} else {
				// previewMessage.recent_message.message = message.message;
				// previewMessage.recent_message.created_at = message.created_at.toString();
				// previewMessage.recent_message.notified = true;
			}
			preview = [...preview];
			// $previewStore = preview;
		}

		const _preview = $previewStore?.find((p) => p.channel_id === $chatPartnerStore);
		if (_preview && _preview.recent_message) {
			_preview.recent_message.message = message.message;
		}
	};

	// Subscribe to incoming messages
	const receiveMessage = () => {
		const unsubscribe = messageStore.subscribe((message: Message1 | null) => {
			if (!message || message.user?.id === $userStore?.id) return;
			handleReceiveMessage($previewStore ?? [], message);
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
		if (!$chatPartnerStore) return;
		const { res, json } = await fetchRequest(
			'GET',
			`chat/message/channel/${$chatPartnerStore}/participant/list`
		);
		if (!res.ok) {
			console.error('Failed to fetch channel participants:', json);
			return;
		}
		participants = json?.results;
	};

	let unsubscribeMessageStore: () => void;

	onMount(() => {
		unsubscribeMessageStore = receiveMessage();
		correctHeightRelativeToHeader();
		window.addEventListener('resize', correctHeightRelativeToHeader);

		let retries = 0;
		let interval: NodeJS.Timeout;
		// Attempt reconnecting websocket when server is shut down
		// Inspired by the user2909737's reply https://stackoverflow.com/questions/3780511/reconnection-of-client-when-server-reboots-in-websocket
		if (!socket) return;
		socket.onclose = () => {
			if (!interval)
				interval = setInterval(() => {
					console.warn('Attempting to reconnect');
					if (socket?.readyState === socket?.OPEN || retries === 50) {
						clearInterval(interval);
						return;
					}
					socket = Socket.createSocket($userStore?.id ?? 0) ?? null;
					retries++;
					// TODO: Add randomness to the interval to prevent many people reconnecting at once if backend issue?
				}, 4000);
		};
	});

	onDestroy(() => {
		if (unsubscribeMessageStore) unsubscribeMessageStore();
		window.removeEventListener('resize', correctHeightRelativeToHeader);
	});

	// Reactive updates
	$: (selectedPage || $chatPartnerStore) && getRecentMessages();
	$: (selectedPage || $chatPartnerStore) && getChannelParticipants();
	$: isLookingAtOlderMessages = !!newerMessages;
	// @ts-ignore
	$: if ($userStore) socket = Socket.createSocket($userStore?.id);
	$: messages &&
		browser &&
		setTimeout(() => {
			if (newerMessages) return;
			const d = document.querySelector('#chat-window');
			d?.scroll(0, 100000);
		}, 100);
</script>

{#if $chatPartnerStore !== 0}
	<div class="flex flex-col h-full">
		<ul class="grow overflow-y-auto px-2 break-word" id="chat-window" bind:this={chatWindow}>
			{#if messages.length === 0 && $chatPartnerStore}
				<span class="self-center">{$_('Chat is currently empty, maybe say hello?')}</span>
			{/if}
			{#if olderMessages}
				<li class="text-center mt-6 mb-6">
					<Button onClick={showOlderMessages}>{$_('Show older messages')}</Button>
				</li>
			{/if}
			{#each messages as message (message.id)}
				{#if message.type === 'info'}
					{@const user = message.user.username}

					<li class="px-4 py-2 max-w-[100%] text-center">
						{$_({ id: 'channelJoin', values: { user } })}
					</li>
				{:else}
					{@const sentByUser = message.user?.id === $userStore?.id}
					<li class="px-4 py-2 max-w-[80%]" class:ml-auto={sentByUser}>
						<span>{message.user?.username}</span>
						<p
							class="p-2 rounded-xl break-words"
							class:bg-primary={sentByUser}
							class:text-white={sentByUser}
							class:bg-gray-300={!sentByUser}
							class:dark:bg-gray-600={sentByUser}
							class:dark:bg-gray-500={!sentByUser}
						>
							{message.message}
						</p>
						<span class="text-[14px] text-gray-400 ml-3">
							<!-- {formatDate(message?.created_at || new Date())} -->
						</span>
					</li>
				{/if}
			{/each}
			{#if newerMessages}
				<li class="text-center mt-6 mb-6">
					<Button onClick={showNewerMessages} buttonStyle="secondary">
						{$_('Show earlier messages')}
					</Button>
				</li>
			{/if}
		</ul>
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
					displayMax={false}
					rows={1}
					bind:value={message}
					placeholder={$_('Write a message...')}
					Class="justify-center w-full h-2rem"
					inputClass="border-0 bg-gray-100 placeholder-gray-700 pl-2 pt-1 resize-y min-h-[2rem] max-h-[6rem] overflow-auto"
				/>
				<!-- {#if env.PUBLIC_MODE === 'DEV'}
					<Button
						onClick={() => (showEmoji = !showEmoji)}
						Class="rounded-full pl-3 pr-3 pt-3 pb-3 h-1/2"
					>
						<Fa icon={faSmile} />
					</Button>
				{/if} -->
				<Button
					type="submit"
					Class="bg-transparent border-none flex items-center justify-center p-3 h-1/2 hover:bg-gray-100 active:bg-gray-200"
				>
					<Fa class="text-blue-600 text-lg" icon={faPaperPlane} />
				</Button>
				<Button
					Class="bg-transparent border-none flex items-center justify-center p-3 h-1/2 hover:bg-gray-100 active:bg-gray-200"
					onClick={() => (participantsModalOpen = true)}
					><Fa class="text-blue-600 text-lg" icon={faUsers} /></Button
				>
			</form>
		</div>
	</div>
{:else}
	<div>{'No chat selected'}</div>
{/if}

<Modal bind:open={participantsModalOpen} Class="max-w-[200px]">
	<div slot="header">{$_('Participants')}</div>
	<div slot="body">
		{#if participants.length > 0}
			<ul>
				{#each participants as participant (participant.id)}
					<ProfilePicture
						displayName
						username={participant.user?.username}
						profilePicture={participant.user?.profile_image}
					/>
				{/each}
			</ul>
		{:else}
			<p>{$_('No participants found.')}</p>
		{/if}
	</div>
</Modal>

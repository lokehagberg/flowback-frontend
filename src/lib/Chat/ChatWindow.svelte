<script lang="ts">
	// @ts-ignore
	import { setTimeStamp, type Message, type PreviewMessage } from './interfaces';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { User } from '$lib/User/interfaces';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import { _ } from 'svelte-i18n';
	import { browser } from '$app/env';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faPaperPlane } from '@fortawesome/free-solid-svg-icons/faPaperPlane';
	import { faSmile } from '@fortawesome/free-solid-svg-icons/faSmile';

	// User Action variables
	let message: string = import.meta.env.VITE_MODE === 'DEV' ? 'a' : '',
		olderMessages: string,
		newerMessages: string,
		showEmoji = false;

	export let selectedChat: number | null,
		sendMessageToSocket: (
			message: string,
			selectedChat: number,
			selectedPage: 'direct' | 'group'
		) => void,
		user: User,
		messages: Message[] = [],
		selectedPage: 'direct' | 'group',
		previewDirect: PreviewMessage[] = [],
		previewGroup: PreviewMessage[] = [],
		isLookingAtOlderMessages: boolean;

	$: (selectedPage || selectedChat) && getRecentMesseges();

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

	const getRecentMesseges = async () => {
		if (!selectedChat) return;

		const { res, json } = await fetchRequest(
			'GET',
			`chat/${selectedPage}/${selectedChat}?order_by=created_at_desc&limit=${5}`
		);

		if (res.ok) messages = json.results.reverse();

		//Temporary fix before json.next issue is fixed
		olderMessages = json.next;
		newerMessages = '';
	};

	//Runs when changing chats
	const postMessage = async () => {
		if (message.length === 0) return;
		if (!selectedChat) return;

		//When sending, go to most recent messages
		if (newerMessages) getRecentMesseges();

		//Updates preview window to display recently typed chat message
		let previewMessage = (selectedPage === 'direct' ? previewDirect : previewGroup).find(
			(previewMessage) =>
				(selectedPage === 'direct' &&
					((previewMessage.user_id === user.id && previewMessage.target_id === selectedChat) ||
						(previewMessage.target_id === user.id && previewMessage.user_id === selectedChat))) ||
				(selectedPage === 'group' && previewMessage.group_id === selectedChat)
		);
		if (previewMessage) {
			previewMessage.message = message;
			previewMessage.created_at = new Date().toString();
		} else {
			//For brand new chats, create new preview message
			(selectedPage === 'direct' ? previewDirect : previewGroup).push({
				created_at: new Date().toString(),
				message,
				timestamp: new Date().toString(),
				username: user.username,
				user_id: user.id,
				target_id: selectedChat,
				target_username: user.username,
				profile_image: '',
				group_id: selectedChat
			});

			previewGroup = previewGroup;
			previewDirect = previewDirect;
		}
		selectedPage === 'direct' ? (previewDirect = previewDirect) : (previewGroup = previewGroup);

		await sendMessageToSocket(message, selectedChat, selectedPage);

		messages.push({
			message,
			user: { username: user.username, id: user.id, profile_image: user.profile_image || '' },
			created_at: new Date().toString()
		});

		messages = messages;
		message = import.meta.env.VITE_MODE === 'DEV' ? message + 'a' : '';

		setTimeStamp(selectedChat, selectedPage);
	};

	$: {
		if (newerMessages) isLookingAtOlderMessages = true;
		else isLookingAtOlderMessages = false;
	}
</script>

{#if selectedChat !== null}
	<ul
		class="col-start-2 col-end-3 bg-white h-100% overflow-y-scroll overflow-x-hidden break-all"
		id="chat-window"
	>
		{#if olderMessages}
			<li class="text-center mt-6 mb-6">
				<ButtonPrimary
					Class=""
					action={async () => {
						const { res, json } = await fetchRequest('GET', olderMessages);

						// nextMessagesAPI = json.next
						newerMessages = json.previous;
						olderMessages = json.next;

						messages = json.results.reverse();
					}}>{$_('Show older messages')}</ButtonPrimary
				>
			</li>
		{/if}
		<!-- <div class="absolute bottom-0 right-0">{$_("New messages")}</div> -->
		{#each messages as message}
			<li class="p-3 hover:bg-gray-200">
				<span>{message.user?.username || message.username}</span>
				<span class="text-[14px] text-gray-400 ml-3">{formatDate(message.created_at)}</span>
				<p>{message.message}</p>
			</li>
		{/each}
		{#if newerMessages}
			<li class="text-center mt-6 mb-6">
				<ButtonPrimary
					action={async () => {
						const { res, json } = await fetchRequest('GET', newerMessages);

						olderMessages = json.next;
						newerMessages = json.previous;

						messages = json.results.reverse();
					}}>{$_('Show earlier messages')}</ButtonPrimary
				>
			</li>
		{/if}
	</ul>
	<!-- <div class:invisible={!showEmoji} class="fixed">
	</div> -->
	<div class="col-start-2 col-end-3 bg-white shadow rounded p-2 w-full">
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
				max={250}
				bind:value={message}
				Class="w-full"
			/>

			{#if import.meta.env.VITE_MODE === 'DEV'}
				<ButtonPrimary
					action={() => (showEmoji = !showEmoji)}
					Class="rounded-full pl-3 pr-3 pt-3 pb-3 h-1/2"><Fa icon={faSmile} /></ButtonPrimary
				>
			{/if}

			<ButtonPrimary type="submit" Class="rounded-full pl-3 pr-3 pt-3 pb-3 h-1/2"
				><Fa icon={faPaperPlane} /></ButtonPrimary
			>
		</form>
	</div>
{:else}
	<div />
{/if}

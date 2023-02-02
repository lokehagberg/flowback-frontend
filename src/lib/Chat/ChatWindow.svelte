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

	// User Action variables
	let message: string, olderMessages: string, newerMessages: string;

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
		previewGroup: PreviewMessage[] = [];

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

		messages = json.results.reverse();

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
		if (previewMessage) previewMessage.message = message;
		selectedPage === 'direct' ? (previewDirect = previewDirect) : (previewGroup = previewGroup);

		await sendMessageToSocket(message, selectedChat, selectedPage);

		messages.push({
			message,
			user: { username: user.username, id: user.id, profile_image: user.profile_image || '' },
			created_at: new Date().toString()
		});

		messages = messages;
		message = '';

		setTimeStamp(selectedChat, selectedPage);
	};
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
	<div class="col-start-2 col-end-3 bg-white shadow rounded p-8 w-full">
		<!-- Here the user writes a message to be sent -->
		<form class="flex gap-2 md:mt-2 lg:mt-5  xl:mt-14" on:submit|preventDefault={postMessage}>
			<TextArea
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
			<ButtonPrimary
				type="submit"
				label="Skicka"
				Class="pl-2 pr-2 pt-2 pb-2 h-[30%] mb-0 mt-[2%] text-sm"
			/>
		</form>
	</div>
{:else}
	<div />
{/if}

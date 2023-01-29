<script lang="ts">
	// @ts-ignore
	import { setTimeStamp, type Message } from './interfaces';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { User } from '$lib/User/interfaces';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import { _ } from 'svelte-i18n';
	import { browser } from '$app/env';

	// User Action variables
	let message: string,
		selectedPage: 'direct' | 'group' = 'direct',
		olderMessages: string,
		newerMessages: string;

	export let selectedChat: number,
		sendMessageToSocket: (message: string, selectedChat: number) => void,
		user: User,
		messages: Message[] = [];

	$: (selectedPage || selectedChat) && getRecentMesseges();

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

		//When sending, go to most recent messages
		if (newerMessages) getRecentMesseges();

		await sendMessageToSocket(message, selectedChat);

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

<ul
	class="col-start-2 col-end-3 bg-white h-[40vh] overflow-y-scroll overflow-x-hidden break-all"
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
	<form class="flex gap-2" on:submit|preventDefault={postMessage}>
		<textarea
			on:keypress={(e) => {
				if (e.key === 'Enter' && !e.shiftKey) {
					postMessage();
					e.preventDefault();
				}
			}}
			required
			bind:value={message}
			class="border border-black  w-full"
			maxlength="2000"
		/>
		<ButtonPrimary type="submit" label="Skicka" Class="" />
	</form>
</div>

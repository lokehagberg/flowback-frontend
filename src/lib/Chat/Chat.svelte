<script lang="ts">
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { onDestroy, onMount } from 'svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Message } from './interfaces';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import type { Writable } from 'svelte/store';
	// import WebSocket from './Socket'

	let messages: Message[] = [{ message: 'haii', time: new Date() }];
	let messageStore: Writable<string>;
	let chatOpen = true;
	let message: string;
	let sendMessageA: (message: string) => void;

	onMount(async () => {
		// const {} await import('./Socket')
		const { subscribe, sendMessage } = (await import('./Socket')).default;
		sendMessageA = sendMessage;
		subscribe((e: any) => {
			console.log(e);
			messages = [...messages, e];
		});
	});

	const SendAMessage = async () => {
		await sendMessageA('haiiiiii');
		message = '';
	};
</script>

<div class="fixed bg-white shadow p-8 z-10">
	{#if chatOpen}
		<div on:click={() => (chatOpen = false)}>
			<Fa icon={faX} />
		</div>
		{#each messages as message}
			{message.message}
		{/each}
		<form on:submit|preventDefault={SendAMessage}>
			<textarea
				on:keypress={(e) => {
					if (e.key === 'Enter' && !e.shiftKey) SendAMessage();
				}}
				label="write a message"
				required
				bind:value={message}
			/>
			<ButtonPrimary type="submit" />
		</form>
	{:else}
		<div on:click={() => (chatOpen = true)}>
			<Fa icon={faPlus} />
		</div>
	{/if}
</div>

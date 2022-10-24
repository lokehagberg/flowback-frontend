<script lang="ts">
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Message } from './interfaces';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';

	let messages: Message[] = [];
	let chatOpen = false;
	let message: string;
	let sendMessageToSocket: (message: string) => void;

	onMount(async () => {
		const { subscribe, sendMessage } = (await import('./Socket')).default;
		sendMessageToSocket = sendMessage(1);
		subscribe((e: any) => {
			const { message, user } = JSON.parse(e);
			messages = [...messages, { message, user }];
		});
	});

	const HandleMessageSending = async () => {
		await sendMessageToSocket(message);
		message = '';
	};
</script>

<div class="fixed bg-white shadow p-8 z-10">
	{#if chatOpen}
		<div on:click={() => (chatOpen = false)}>
			<Fa icon={faX} />
		</div>
		{#each messages as message}
			<div>{message.message}</div>
		{/each}
		<form on:submit|preventDefault={HandleMessageSending}>
			<textarea
				on:keypress={(e) => {
					if (e.key === 'Enter' && !e.shiftKey) HandleMessageSending();
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

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
		//Must be imported here to avoid "document not found" error
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

<div class="fixed z-10">
	{#if chatOpen}
	<div class="w-full bg-white shadow rounded p-8">
		<div on:click={() => (chatOpen = false)} class="cursor-pointer p-2">
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
	</div>
	{:else}
		<div on:click={() => (chatOpen = true)} class="bg-white shadow rounded p-10 cursor-pointer">
			<Fa icon={faPlus} />
		</div>
	{/if}
</div>

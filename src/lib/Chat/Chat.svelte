<script lang="ts">
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Message } from './interfaces';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';

	let messages: Message[] = [{ message: 'haii', time: new Date() }];
	let socket: WebSocket;
	let chatOpen = true;
    let message:string;

	onMount(async () => {
		socket = (await import('./Socket')).socket;
	});

	const sendMessage =async () => {
		console.log('lol');
        await setTimeout(() => {
            
        }, 1000);
        message = ""
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
		<form on:submit|preventDefault={sendMessage}>
			<textarea
				on:keypress={(e) => {
                    console.log(e)
					if (e.key === 'Enter' && !e.shiftKey) sendMessage();
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

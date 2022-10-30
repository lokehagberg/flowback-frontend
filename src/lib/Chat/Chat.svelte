<script lang="ts">
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Message } from './interfaces';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Group } from '$lib/Group/interface';

	let messages: Message[] = [];
	let chatOpen = true;
	let message: string;
	let groups: Group[] = [];
	let socket: WebSocket;
	let sendMessageToSocket: (message: string) => void;

	onMount(async () => {
		groups = await getGroups();
		// setUpMessageSending();
	});

	const setUpMessageSending = async (selectedGroup: number) => {
		//Must be imported here to avoid "document not found" error
		const { createSocket, subscribe, sendMessage } = (await import('./Socket')).default;

		if (socket) socket.close();
		socket = createSocket(selectedGroup);
		try {
			sendMessageToSocket = sendMessage(selectedGroup, socket);
			subscribe((e: any) => {
				const { message, user } = JSON.parse(e);
				messages = [...messages, { message, user }];
			});
		} catch (e) {}
	};

	const HandleMessageSending = async () => {
		await sendMessageToSocket(message);
		message = '';
	};

	const getGroups = async () => {
		const { res, json } = await fetchRequest('GET', `group/list?joined=true&limit=100`);
		return json.results;
	};
</script>

{#if chatOpen}
	<div class="bg-white fixed z-10 w-full">
		<div
			on:click={() => (chatOpen = false)}
			class="flex justify-between bg-white border border-gray-300 hover:border-gray-600 cursor-pointer p-2 "
		>
			<div class="">Chat</div>
			<Fa icon={faX} />
		</div>
		<ul class="bg-white">
			{#each messages as message}
				<li>{message.message}</li>
			{/each}
		</ul>
		<ul class="bg-white">
			{#each groups as group}
				<li on:click={() => setUpMessageSending(group.id)}>
					<img
						class="w-10 h-10"
						src={`${import.meta.env.VITE_API}${group.image}`}
						alt="group profile"
					/>
				</li>
			{/each}
		</ul>
		<div class="w-full bg-white shadow rounded p-8 w-full">
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
	</div>
{:else}
	<div
		on:click={() => (chatOpen = true)}
		class="fixed z-30 bg-white shadow rounded p-6 top-1/4 cursor-pointer"
	>
		<Fa icon={faPlus} />
	</div>
{/if}

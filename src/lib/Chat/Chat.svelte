<script lang="ts">
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Message } from './interfaces';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Group } from '$lib/Group/interface';
	import Tab from '$lib/Generic/Tab.svelte';

	let messages: Message[] = [];
	let chatOpen = true;
	let message: string;
	let groups: Group[] = [];
	let socket: WebSocket;
	let sendMessageToSocket: (message: string) => void;
	let selectedPage: 'Direkt' | 'Grupper' = 'Direkt';

	//TODO: Only render when chat opens up
	onMount(async () => {
		groups = await getGroups();

		// setUpMessageSending();
	});

	const setUpMessageSending = async (selectedGroup: number) => {
		//Must be imported here to avoid "document not found" error
		const { createSocket, subscribe, sendMessage } = (await import('./Socket')).default;

		const { res, json } = await fetchRequest('GET', `chat/group/${selectedGroup}`);
		if (socket) await socket.close();
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
	<div class="bg-white fixed z-10 w-full grid">
		<div
			on:click={() => (chatOpen = false)}
			class="col-start-2 col-end-3 flex justify-between bg-white border border-gray-300 hover:border-gray-600 cursor-pointer p-2 "
		>
			<div class="">Chat</div>
			<Fa icon={faX} />
		</div>
		<div class="col-start-1 col-end-2 row-start-1 row-end-2">
		<Tab bind:selectedPage tabs={['Direkt', 'Grupper']} />
	</div>
		<ul
			class="col-start-2 col-end-3 bg-white h-[40vh] overflow-y-scroll overflow-x-hidden break-all"
		>
			{#each messages as message}
				<li>{message.message}</li>
			{/each}
		</ul>
		<ul class="row-start-2 row-end-4 bg-white">
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
		<div class="col-start-2 col-end-3 w-full bg-white shadow rounded p-8 w-full">
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

<script lang="ts">
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Message } from './interfaces';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import { faComment } from '@fortawesome/free-solid-svg-icons/faComment';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Group } from '$lib/Group/interface';
	import Tab from '$lib/Generic/Tab.svelte';
	import type { Unsubscriber } from 'svelte/store';
	import DefaultPFP from '$lib/assets/Default_pfp.png';

	let messages: Message[] = [];
	let chatOpen = false;
	let message: string;
	let groups: Group[] = [];
	let directs: any[] = [];
	let socket: WebSocket;
	let sendMessageToSocket: (message: string) => void;
	let selectedPage: 'Direkt' | 'Grupper' = 'Direkt';
	let unsubscribe: Unsubscriber;

	$: chatOpen && getChattable();

	const getChattable = async () => {
		if (directs.length + groups.length !== 0) return;
		directs = await getPeople('');
		groups = await getGroups();
	};

	const setUpMessageSending = async (selectedGroup: number) => {
		//Must be imported here to avoid "document not found" error
		const { createSocket, subscribe, sendMessage } = (await import('./Socket')).default;

		const { res, json } = await fetchRequest(
			'GET',
			selectedPage === 'Grupper' ? `chat/group/${selectedGroup}` : `chat/direct/${selectedGroup}`
		);
		messages = json.results;

		//Resets last web socket connection
		if (socket) socket.close();
		if (unsubscribe) unsubscribe();

		socket = createSocket(selectedGroup, selectedPage);
		try {
			sendMessageToSocket = sendMessage(selectedGroup, socket);
			unsubscribe = subscribe((e: any) => {
				console.log(e, 'EE');
				const { message, user } = JSON.parse(e);
				messages = [...messages, { message, user }];

				//TODO: make a better solution to scrolling down when sending/being sent message
				setTimeout(() => {
					document.querySelector('.overflow-y-scroll')?.scroll(0, 100000);
				}, 100);
			});
		} catch (e) {
			console.error(e);
		}
	};

	const HandleMessageSending = async () => {
		await sendMessageToSocket(message);
		// messages = [...messages, {message, user: {username:"Jag", id} }]
		message = '';
	};

	const getGroups = async () => {
		const { res, json } = await fetchRequest('GET', `group/list?joined=true&limit=100`);
		return json.results;
	};

	const getPeople = async (username: string) => {
		const { json } = await fetchRequest('GET', `users?limit=100`);
		const self = (await fetchRequest('GET', `user`)).json;
		return json.results.filter((user: any) => user.id !== self.id);
	};
</script>

{#if chatOpen}
	<div class="bg-white fixed z-10 w-full grid">
		<div
			class="col-start-2 col-end-3 flex justify-between bg-white border border-gray-300 p-2 "
		>
			<div class="">Chat</div>
			<div class="cursor-pointer" on:click={() => (chatOpen = false)}>
				<Fa size="1.5x" icon={faX} />
			</div>
		</div>
		<div class="col-start-1 col-end-2 row-start-1 row-end-2">
			<Tab bind:selectedPage tabs={['Direkt', 'Grupper']} />
		</div>
		<ul
			class="col-start-2 col-end-3 bg-white h-[40vh] overflow-y-scroll overflow-x-hidden break-all"
		>
			{#each messages as message}
				<li class="p-3 hover:bg-gray-200">
					<span>{message.user?.username || message.username}</span>
					<p>{message.message}</p>
				</li>
			{/each}
		</ul>
		<ul class="row-start-2 row-end-4 bg-white flex flex-col ml-3 mt-3">
			{#each selectedPage === 'Grupper' ? groups : directs as chatter}
				<li
					class="p-3 flex gap-2 hover:bg-gray-200 cursor-pointer"
					on:click={() => setUpMessageSending(chatter.id)}
				>
					<img
						class="w-10 h-10 rounded-full"
						src={chatter.image ? `${import.meta.env.VITE_API}${chatter.image}` : DefaultPFP}
						alt=""
					/>
					<span>{chatter.name || chatter.username}</span>
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
					class="border border-black w-full"
				/>
				<ButtonPrimary type="submit" label="Skicka" />
			</form>
		</div>
	</div>
{:else}
	<div
		on:click={() => (chatOpen = true)}
		class="fixed z-30 bg-white shadow-md border rounded p-6 top-3/4 ml-6 rounded-full cursor-pointer hover:shadow-xl hover:border-black active:shadow-2xl active:p-7"
	>
		<Fa icon={faComment} />
	</div>
{/if}

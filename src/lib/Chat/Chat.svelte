<script lang="ts">
	import { onDestroy, onMount } from 'svelte';
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
	import type { User } from '$lib/User/interfaces';
	import { formatDate } from '$lib/Generic/DateFormatter';

	let messages: Message[] = [];
	let chatOpen = false;
	let message: string;
	let groups: Group[] = [];
	let directs: any[] = [];
	let socket: WebSocket;
	let sendMessageToSocket: (message: string) => void;
	let selectedPage: 'Direkt' | 'Grupper' = 'Direkt';
	let unsubscribe: Unsubscriber;
	let chatSelected: number;
	let isChangingSocket = false;
	let user: User;
	let olderMessagesAPI: string;
	let newerMessagesAPI: string;

	$: chatOpen && getChattable();

	const getChattable = async () => {
		if (directs.length + groups.length !== 0) return;

		const { json, res } = await fetchRequest('GET', 'user');
		user = json;

		directs = await getPeople('');
		groups = await getGroups();
	};

	const setUpMessageSending = async (selectedChat: number) => {
		//Resets last web socket connection
		if (socket) await socket.close();
		if (unsubscribe) await unsubscribe();

		chatSelected = selectedChat;

		const { res, json } = await fetchRequest(
			'GET',
			selectedPage === 'Grupper'
				? `chat/group/${selectedChat}`
				: `chat/direct/${selectedChat}?order_by=created_at_desc&limit=${4}`
		);

		messages = json.results.reverse();
		// nextMessagesAPI = json.next;

		//Temporary fix before json.next issue is fixed
		olderMessagesAPI = json.next;

		//Must be imported here to avoid "document not found" error
		const { createSocket, subscribe, sendMessage } = (await import('./Socket')).default;
		socket = createSocket(selectedChat, selectedPage, user.id);
		isChangingSocket = true;

		//TODO: Remove timeouts
		setTimeout(() => {
			const d = document.querySelector('.overflow-y-scroll');
			d?.scroll(0, 100000);
		}, 100);

		try {
			sendMessageToSocket = await sendMessage(selectedChat, socket);
			unsubscribe = subscribe((e: any) => {
				console.log('EE');
				const { message, user } = JSON.parse(e);
				messages = [...messages, { message, user, created_at: new Date().toString() }];

				//TODO: make a better solution to scrolling down when sending/being sent message
				setTimeout(() => {
					const d = document.querySelector('.overflow-y-scroll');
					d?.scroll(0, 100000);
				}, 100);
			});
		} catch (e) {
			console.error(e);
		}
	};

	const HandleMessageSending = async () => {
		await sendMessageToSocket(message);
		messages.push({
			message,
			user: { username: user.username, id: user.id, profile_image: user.profile_image }
		});
		messages = messages;
		message = '';
		setTimeout(() => {
			const d = document.querySelector('.overflow-y-scroll');
			d?.scroll(0, 100000);
		}, 100);
	};

	const getGroups = async () => {
		const { res, json } = await fetchRequest('GET', `group/list?joined=true&limit=100`);
		return json.results;
	};

	const getPeople = async (username: string) => {
		const { json } = await fetchRequest('GET', `users?limit=100`);
		// const self = (await fetchRequest('GET', `user`)).json;
		return json.results.filter((chatter: any) => chatter.id !== user.id);
	};

	onDestroy(() => {
		if (unsubscribe) unsubscribe();
		if (socket) socket.close();
	});

	$: messages && manamgeMessageScroll();

	const manamgeMessageScroll = () => {};
</script>

{#if chatOpen}
	<div class="bg-white fixed z-10 w-full grid grid-width-fix">
		<div class="col-start-2 col-end-3 flex justify-between bg-white border border-gray-300 p-2 ">
			<div class="">Chatt</div>
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
			{#if olderMessagesAPI}
				<li class="text-center mt-6 mb-6">
					<ButtonPrimary
						Class=""
						action={async () => {
							const { res, json } = await fetchRequest('GET', olderMessagesAPI);

							// nextMessagesAPI = json.next
							newerMessagesAPI = json.previous;
							olderMessagesAPI = json.next;

							messages = json.results.reverse();
						}}>Visa äldre medelanden</ButtonPrimary
					>
				</li>
			{/if}
			{#each messages as message}
				<li class="p-3 hover:bg-gray-200">
					<span>{message.user?.username || message.username}</span>
					<span class="text-[14px] text-gray-400 ml-3">{formatDate(message.created_at)}</span>
					<p>{message.message}</p>
				</li>
			{/each}
			{#if newerMessagesAPI}
				<li class="text-center mt-6 mb-6">
					<ButtonPrimary
						Class=""
						action={async () => {
							const { res, json } = await fetchRequest('GET', newerMessagesAPI);

							olderMessagesAPI = json.next;
							newerMessagesAPI = json.previous;

							messages = json.results.reverse();
						}}>Visa tidigare medelanden</ButtonPrimary
					>
				</li>
			{/if}
		</ul>
		<ul
			class="row-start-2 row-end-4 bg-white flex flex-col sm:h-[30-vh] md:h-[80vh] lg:h-[90vh] overflow-y-scroll"
		>
			{#each selectedPage === 'Grupper' ? groups : directs as chatter}
				<li
					class="transition transition-color p-3 flex gap-2 hover:bg-gray-200 active:bg-gray-500 cursor-pointer"
					class:bg-gray-200={chatSelected === chatter.id}
					on:click={() => {
						if (socket?.CLOSED || socket === undefined) return setUpMessageSending(chatter.id);
					}}
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
		class="transition transition-all fixed z-30 bg-white shadow-md border rounded p-6 bottom-6 ml-6 rounded-full cursor-pointer hover:shadow-xl hover:border-black active:shadow-2xl active:p-7"
	>
		<Fa icon={faComment} />
	</div>
{/if}

<style>
	.grid-width-fix {
		grid-template-columns: 30% 70%;
		grid-template-rows: 3rem 50vh 50vh;
	}
</style>

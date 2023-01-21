<script lang="ts">
	import { onDestroy, onMount } from 'svelte';
	// @ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Message } from './interfaces';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faComment } from '@fortawesome/free-solid-svg-icons/faComment';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Group } from '$lib/Group/interface';
	import Tab from '$lib/Generic/Tab.svelte';
	import type { Unsubscriber } from 'svelte/store';
	import type { User } from '$lib/User/interfaces';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import { _ } from 'svelte-i18n';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import TestToggle from '$lib/Generic/TestToggle.svelte';
	import Selected from '$lib/Group/Delegation/Selected.svelte';

	// User Action variables
	let messages: Message[] = [],
		chatOpen = false,
		message: string,
		user: User,
		// Specifies which chat window is open
		groups: Group[] = [],
		directs: any[] = [],
		selectedPage: 'direct' | 'group' = 'direct',
		selectedChat: number,
		notified: number[] = [],
		preview: any[] = [],
		//Websocket utility functions and variables
		socket: WebSocket,
		sendMessageToSocket: (message: string) => void,
		unsubscribe: Unsubscriber,
		//Chat history
		olderMessagesAPI: string,
		newerMessagesAPI: string,
		displayNotificationGlobal = false;

	// $: chatOpen && openFirstTime();

	onMount(() => {
		openFirstTime();
	})

	const openFirstTime = async () => {
		await getChattable();
		setUpMessageSending();
	};

	const getChattable = async () => {
		if (user) return;

		if (directs.length + groups.length !== 0) return;

		const { json, res } = await fetchRequest('GET', 'user');
		user = json;

		directs = await getPeople();
		groups = await getGroups();
	};

	$: (selectedPage || selectedChat) && setUpMessageSending();

	const setUpMessageSending = async () => {
		if (!user) return;

		if (unsubscribe) unsubscribe();

		preview = [];

		getPreview();

		getRecentMesseges();

		// await unsubscribe();

		//Must be imported here to avoid "document not found" error
		const { createSocket, subscribe, sendMessage } = (await import('./Socket')).default;
		if (!socket) socket = createSocket(user.id);

		sendMessageToSocket = await sendMessage(selectedChat, socket, selectedPage)	

		//This function triggers every time a message arrives from the socket
		//Bug: This happends even when switching chats
		unsubscribe = subscribe(handleNewChatMessage);
	};

	const handleNewChatMessage = async (e: any) => {
		//Try-catch to prevent error end at JSON string
		try {
			var { message, user } = JSON.parse(e);
		} catch (err) {
			return;
		}

		//Messages from other chats are not put in chat
		if (selectedChat !== user.id) return;

		//New message recieved, add to list of notifications to show to user
		// if (user.id && !notified.includes(user.id)) {
		// 	notified.push(user.id);
		// 	notified = notified;
		// }

		console.log("Huhuhu")
		getPreview();

		//If most recent messeges are shown, display new message and scroll
		if (!newerMessagesAPI) {
			messages = [...messages, { message, user, created_at: new Date().toString() }];

			//TODO: make a better solution to scrolling down when sending/being sent message
			await setTimeout(() => {
				//If scrolled furtherst down, scroll whenever a message is recieved
				const d = document.querySelector('.overflow-y-scroll');
				d?.scroll(0, 100000);
			}, 100);
		}
	};

	const getRecentMesseges = async () => {
		if (!selectedChat) return;

		const { res, json } = await fetchRequest(
			'GET',
			`chat/${selectedPage}/${selectedChat}?order_by=created_at_desc&limit=${5}`
		);

		messages = json.results.reverse();

		//Temporary fix before json.next issue is fixed
		olderMessagesAPI = json.next;
		newerMessagesAPI = '';

		//TODO: Replace this with something better
		await setTimeout(() => {
			const d = document.querySelector('.overflow-y-scroll');
			d?.scroll(0, 100000);
		}, 100);
	};

	const HandleMessageSending = async () => {
		if (message.length === 0) return;

		//When sending, go to most recent messages
		if (newerMessagesAPI) getRecentMesseges();
		
		await sendMessageToSocket(message);
		// preview.find(message => message.id === selectedChat).text = message

		messages.push({
			message,
			user: { username: user.username, id: user.id, profile_image: user.profile_image || '' },
			created_at: new Date().toString()
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

	const getPeople = async () => {
		const { json } = await fetchRequest('GET', `users?limit=100`);
		return json.results.filter((chatter: any) => chatter.id !== user.id);
	};

	const getPreview = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`chat/${selectedPage}/preview?order_by=created_at_desc`
		);
		preview = json.results;

		notified = json.results
			.filter((message: any) => message.timestamp < message.created_at)
			.map((message: any) => (message.target_id === user.id ? message.user_id : message.target_id));
	};

	const clickedChatter = (chatter: any) => {
		//Gets rid of existing notification when clicked on new chat
		notified = notified.filter((notis) => notis !== chatter.id);
		notified = notified;

		//Switches chat shown to the right of the screen to chatter
		if (selectedChat !== chatter.id) selectedChat = chatter.id;

		setTimeStamp(chatter.id);
	};

	//User has looked at a message, affects /preview primarily.
	const setTimeStamp = async (chatterId: number) => {
		fetchRequest('POST', `chat/${selectedPage}/${chatterId}/timestamp`, {
			timestamp: new Date()
		});
	};

	$: if (notified.length > 0) displayNotificationGlobal = true 
	else displayNotificationGlobal=false

	onMount(() => {});

	// onMount(async () => {
	// 	getPreview();

	// fetchRequest('GET', 'notification')
	// 	fetchRequest('POST', 'notification/subscriptions')
	// 	fetchRequest('POST', 'notification/read')
	// 	fetchRequest('POST', 'group/2/subscribe', {categories:['group']})

	// 	// fetchRequest('POST', 'chat/direct/2/timestamp', {
	// });
</script>

<!-- <ButtonPrimary action={() => {
	fetchRequest('GET', 'notification')
	// fetchRequest('POST', 'kanban/subscribe', {kanban:2})
	fetchRequest('POST', 'group/2/subscribe', {categories:['poll']})
	// fetchRequest('GET', 'chat/group/preview')
	// fetchRequest('POST', 'group/2/poll/28/subscribe', {categories:['timeline', 'poll']})
	// fetchRequest('POST', 'chat/group/2/timestamp', {
	// 	timestamp :new Date()
	// })
}}
/> -->

{#if chatOpen}
	<div class="bg-white fixed z-40 w-full grid grid-width-fix">
		<!-- <TestToggle action={getPreview} loopTime={7000}/> -->
		<!-- <TestToggle
			action={async () => {
				const { res, json } = await fetchRequest(
					'GET',
					'chat/direct/preview?order_by=created_at_desc'
				);
			}}
			loopTime={5000}
		/> -->

		<div class="col-start-2 col-end-3 flex justify-between bg-white border border-gray-300 p-2 ">
			<div class="text-xl font-light text-gray-500">{$_('Chat')}</div>
			<div class="cursor-pointer" on:click={() => (chatOpen = false)}>
				<Fa size="1.5x" icon={faX} />
			</div>
		</div>
		<div class="col-start-1 col-end-2 row-start-1 row-end-2">
			<Tab bind:selectedPage tabs={['direct', 'group']} displayNames={['Direct', 'Groups']} />
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
			{#if newerMessagesAPI}
				<li class="text-center mt-6 mb-6">
					<ButtonPrimary
						Class=""
						action={async () => {
							const { res, json } = await fetchRequest('GET', newerMessagesAPI);

							olderMessagesAPI = json.next;
							newerMessagesAPI = json.previous;

							messages = json.results.reverse();
						}}>{$_('Show earlier messages')}</ButtonPrimary
					>
				</li>
			{/if}
		</ul>
		<ul
			class="row-start-2 row-end-4 bg-white flex flex-col sm:h-[30-vh] md:h-[80vh] lg:h-[90vh] overflow-y-scroll"
		>
			{#each selectedPage === 'group' ? groups : directs as chatter}
				<li
					class="transition transition-color p-3 flex items-center gap-3 hover:bg-gray-200 active:bg-gray-500 cursor-pointer"
					class:bg-gray-200={selectedChat === chatter.id}
					on:click={() => clickedChatter(chatter)}
				>
					{#if notified.includes(chatter.id)}
						<div class="bg-purple-400 p-1 rounded-full" />
					{/if}
					<ProfilePicture user={chatter} />
					<div class="flex flex-col">
						<span>{chatter.name || chatter.username}</span>
						<span class="text-gray-400 text-sm truncate h-[20px]">
							{preview.find(
								(message) =>
									(user.id !== message.target_id && message.target_id === chatter.id) ||
									(user.id !== message.user_id && message.user_id === chatter.id) ||
									message.group_id === chatter.id
							)?.message || ''}
						</span>
					</div>
				</li>
			{/each}
		</ul>
		<div class="col-start-2 col-end-3 w-full bg-white shadow rounded p-8 w-full">
			<!-- Here the user writes a message to be sent -->
			<form class="flex gap-2" on:submit|preventDefault={HandleMessageSending}>
				<textarea
					on:keypress={(e) => {
						if (e.key === 'Enter' && !e.shiftKey) {
							HandleMessageSending();
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
	</div>
{:else}
	<div
		on:click={() => (chatOpen = true)}
		class:small-notification={displayNotificationGlobal}
		class="transition transition-all fixed z-30 bg-white shadow-md border p-9 bottom-6 ml-6 rounded-full cursor-pointer hover:shadow-xl hover:border-gray-400 active:shadow-2xl active:p-7"
	>
		<Fa icon={faComment} />
	</div>
{/if}

<style>
	.grid-width-fix {
		grid-template-columns: 30% 70%;
		grid-template-rows: 3rem 50vh 50vh;
	}

	.small-notification:before {
		position: absolute;
		content: '';
		top: 0;
		right: 0;
		background-color: rgb(167, 139, 250);
		border-radius: 100%;
		padding: 10px;
	}
</style>

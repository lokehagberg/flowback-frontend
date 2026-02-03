<script lang="ts">
	import { groupStore, workgroupStore } from '$lib/Group/Kanban/Kanban';
	import ChatWindow from './ChatWindow.svelte';
	import Preview from './Preview.svelte';
	import { onMount } from 'svelte';
	import type { GroupMembers, PreviewMessage } from './interfaces';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import Button from '$lib/Generic/Button.svelte';
	import { faCog } from '@fortawesome/free-solid-svg-icons';
	import ChatIcon from '$lib/assets/Chat_fill.svg';
	import { darkModeStore, getIconFilter } from '$lib/Generic/DarkMode';
	import {
		chatOpenStore,
		fixDirectMessageChannelName,
		previewStore,
		chatPartnerStore
	} from './functions';
	import { goto } from '$app/navigation';
	import CreateChatGroup from '$lib/Chat/CreateChatGroup.svelte';
	import CrossButton from '$lib/Generic/CrossButton.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { userStore } from '$lib/User/interfaces';

	let chatOpen = false,
		selectedPage: 'direct' | 'group' = 'direct',
		isLookingAtOlderMessages = false,
		chatDiv: HTMLDivElement,
		creatingGroup = false,
		groupMembers: GroupMembers[] = [],
		notification = false;

	// Fetch preview messages and set notified based on localStorage timestamps
	const getPreview = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`chat/message/channel/preview/list`
		);
		if (!res.ok) return [];

		let previews = json?.results.map((preview: PreviewMessage) => {
			return {
				...preview,
				recent_message: {
					...preview.recent_message,
					notified:
						// Makes sure that messages are notified whenever most recent message is before last click
						// @ts-ignore
						preview.recent_message === null ||
						new Date(preview.timestamp) >
							new Date(preview.recent_message?.created_at) ||
						preview.recent_message?.user.id === $userStore?.id
				}
			};
		});

		$previewStore = previews;

		fixDirectMessageChannelName(json?.results, $userStore?.id);
	};

	// Adjust chat window based on the header
	const correctMarginRelativeToHeader = () => {
		const _headerHeight = document.querySelector('#header')?.clientHeight;
		if (_headerHeight && chatDiv)
			chatDiv.style.marginTop = `${_headerHeight.toString()}px`;
	};

	onMount(async () => {
		// Adjust chat window margin based on header height
		// TODO: Make better (CSS Only perhaps)
		correctMarginRelativeToHeader();
		window.addEventListener('resize', correctMarginRelativeToHeader);

		// Subscribe to chat open state
		chatOpenStore.subscribe((open) => (chatOpen = open));
		getPreview();

		groupStore.subscribe(() => getPreview());
		workgroupStore.subscribe(() => getPreview());
	});

	// Display purple notification circle whenever there is a message that hasn't been seen.
	$: notification = $previewStore.some((p) => !p.recent_message?.notified);
</script>

<svelte:head>
	<title>
		{`${notification ? '🟣' : ''}`}
	</title>
</svelte:head>

<div
	bind:this={chatDiv}
	class:invisible={!chatOpen}
	class="bg-background dark:bg-darkbackground dark:text-darkmodeText fixed z-[50] w-[100vw] h-[100vh] flex flex-col items-center"
>
	<div class="w-full flex justify-between mr-6">
		<Button
			onClick={() => {
				chatOpen = false;
				chatOpenStore.set(false);
				goto('/user/settings');
			}}
			Class="px-6 my-3 dark:bg-darkbackground hover:brightness-95 active:brightness-90"
		>
			<div
				class={`top-3 right-2.5 text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm p-1.5 ml-auto inline-flex items-center dark:hover:bg-gray-800 dark:hover:text-white`}
			>
				<Fa icon={faCog} />
			</div>
		</Button>

		<Button
			Class="px-6 my-3 dark:bg-darkbackground hover:brightness-95 active:brightness-90"
		/>
		<CrossButton
			action={() => {
				chatOpen = false;
				chatOpenStore.set(false);
			}}
		/>
	</div>

	<div class="flex w-full gap-6 max-w-[1200px] h-[80vh]">
		<div
			class="bg-white w-[40%] overflow-y-auto flex-grow ml-6 dark:bg-darkobject p-2"
		>
			{#key creatingGroup}
				<Preview bind:creatingGroup bind:groupMembers />
			{/key}
		</div>
		<div class="bg-white w-[60%] flex-grow mr-6 dark:bg-darkobject p-2">
			{#if creatingGroup}
				<CreateChatGroup bind:creatingGroup bind:groupMembers />
			{:else}
				<ChatWindow bind:selectedPage bind:isLookingAtOlderMessages />
			{/if}
		</div>
	</div>
</div>

<button
	on:click={() => {
		chatOpen = !chatOpen;
		chatOpenStore.set(chatOpen);
	}}
	class:small-notification={notification}
	class="dark:text-white transition-all fixed z-50 bg-white dark:bg-darkobject shadow-md border p-5 bottom-6 ml-5 rounded-full cursor-pointer hover:shadow-xl hover:border-gray-400 active:shadow-2xl active:p-6"
>
	<img
		src={ChatIcon}
		class="text-white"
		style="filter: {getIconFilter(true, 'white', $darkModeStore)}"
		alt={chatOpen ? 'close chat' : 'open chat'}
	/>
</button>

<style>
	.small-notification:before {
		position: absolute;
		content: '';
		top: 0;
		right: 0;
		background-color: rgb(167, 139, 250);
		border-radius: 100%;
		padding: 10px;
		z-index: 10;
	}
</style>

<script lang="ts">
	import ChatWindow from './ChatWindow.svelte';
	import Preview from './Preview.svelte';
	import { onMount } from 'svelte';
	// @ts-ignore
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Message, PreviewMessage } from './interfaces';
	import { faComment } from '@fortawesome/free-solid-svg-icons/faComment';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { User } from '$lib/User/interfaces';
	import { _ } from 'svelte-i18n';
	import CrossButton from '$lib/Generic/CrossButton.svelte';
	import { updateUserData } from './functions';

	let chatOpen = import.meta.env.VITE_MODE === 'DEV' ? false : false,
		user: User,
		// Specifies which chat window is open
		selectedPage: 'direct' | 'group' = 'direct',
		selectedChat: number | null,
		//The preview page on the left side of the chat screen
		previewDirect: PreviewMessage[] = [],
		previewGroup: PreviewMessage[] = [],
		notifiedDirect: number[] = [],
		notifiedGroup: number[] = [],
		isLookingAtOlderMessages = false,
		chatDiv: HTMLDivElement;

	onMount(async () => {
		await getUser();
		// await setUpMessageSending();
		// console.log(socket, user, user.id, 'IDD');

		// testNewAPI();
		correctMarginRelativeToHeader();
		window.addEventListener('resize', correctMarginRelativeToHeader);
	});

	const correctMarginRelativeToHeader = () => {
		const _headerHeight = document.querySelector('#header')?.clientHeight;
		if (_headerHeight && chatDiv) chatDiv.style.marginTop = `${_headerHeight.toString()}px`;
	};

	//TODO: Turn all these get users into one unified svelte store for fewer API calls
	const getUser = async () => {
		const { json, res } = await fetchRequest('GET', 'user');
		if (res.ok) user = json;
		if (!res.ok) return;
	};

	$: if (chatOpen === false) {
		if (selectedChat) updateUserData(selectedChat, null, new Date());
		selectedChat = null;
		// selectedPage === 'direct';
	}
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<!-- svelte-ignore a11y-click-events-have-key-events -->
<svelte:head>
	<title>
		{`${notifiedDirect.length > 0 ? '🟣' : ''}${notifiedGroup.length > 0 ? '🔵' : ''}`}
	</title>
</svelte:head>
<div
	bind:this={chatDiv}
	class:invisible={!chatOpen}
	class="bg-white dark:bg-darkobject dark:text-darkmodeText fixed z-40 w-full grid grid-width-fix h-[100wh]"
>
	<div class="col-start-2 col-end-3 flex justify-between bg-white dark:bg-darkobject p-2">
		<div class="text-xl font-light text-gray-400">{$_('Chat')}</div>

		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<div class="w-full h-full" on:keydown>
			<CrossButton Class="cursor-pointer" action={() => (chatOpen = false)}/>
		</div>
	</div>
	<Preview bind:selectedChat bind:selectedPage bind:previewDirect bind:previewGroup />
	<ChatWindow
		bind:selectedChat
		bind:selectedPage
		bind:previewDirect
		bind:previewGroup
		bind:isLookingAtOlderMessages
		{user}
	/>
</div>
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	on:click={() => (chatOpen = true)}
	on:keydown
	class:small-notification={notifiedDirect.length > 0}
	class:small-notification-group={notifiedGroup.length > 0}
	class="dark:text-white transition-all fixed z-30 bg-white dark:bg-darkobject shadow-md border p-6 bottom-6 ml-6 rounded-full cursor-pointer hover:shadow-xl hover:border-gray-400 active:shadow-2xl active:p-7"
>
	<Fa icon={faComment} size="1.3x" />
</div>

<style>
	.grid-width-fix {
		grid-template-columns: 30% 70%;
		grid-template-rows: 2.9rem 58vh 28vh;
		/* 100vh to stretch the calendar to the bottom, then we subtract 2 rem from the padding
    on the header, 40px from the height of each symbol/the logo on the header, and 
    28 px for the controlls on the calendar. This scuffed solution might need to be improved */
		height: calc(100vh - 2rem - 40px - 28px);
	}

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

	.small-notification-group:after {
		position: absolute;
		content: '';
		top: 10px;
		right: 0;
		background-color: rgb(147, 197, 235);
		border-radius: 100%;
		padding: 10px;
	}
</style>

<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { Thread } from './interface';
	import Pagination from '$lib/Generic/Pagination.svelte';
	import { goto } from '$app/navigation';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import Fa from 'svelte-fa';
	import {
		faArrowDown,
		faArrowUp,
		faComment,
		faThumbsDown,
		faThumbsUp,
		faThumbTack,
		faMagnifyingGlass
	} from '@fortawesome/free-solid-svg-icons';
	import { threads as threadsLimit } from '$lib/Generic/APILimits.json';
	import { _ } from 'svelte-i18n';
	import Description from '$lib/Poll/Description.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Button from '$lib/Generic/Button.svelte';

	export let isAdmin = true;

	let threads: Thread[] = [],
		prev = '',
		next = '',
		poppup: poppup,
		searchQuery = '',
		searched = true;

	const getThreads = async () => {
		let url = `group/${$page.params.groupId}/thread/list?limit=${threadsLimit}&order_by=pinned`;
		if (searchQuery) {
			url += `&title__icontains=${searchQuery}`;
		}

		const { res, json } = await fetchRequest('GET', url);

		if (!res.ok) {
			poppup = { message: 'Could not load threads', success: false };
			return;
		}

		next = json.next;
		prev = json.previous;
		threads = json.results;
	};

	const handleSearch = () => {
		searched = true;
		getThreads();
	};

	//Launches whenever the user clicks upvote or downvote on a thread
	const threadVote = async (thread: Thread, clicked: 'down' | 'up') => {
		let vote: null | false | true = null;

		if (thread.user_vote === false && clicked === 'down') vote = null;
		else if (clicked === 'down') vote = false;
		else if (thread.user_vote === true && clicked === 'up') vote = null;
		else if (clicked === 'up') vote = true;

		const { res, json } = await fetchRequest('POST', `group/thread/${thread.id}/vote`, { vote });

		if (!res.ok) {
			poppup = { message: 'Could not vote on thread', success: false };
			return;
		}

		//TODO: Make this more efficient by not having to reload threads.
		getThreads();
	};

	//When adminn presses the pin tack symbol, pin the thread
	const pinThread = async (thread: Thread) => {
		const { json, res } = await fetchRequest('POST', `group/thread/${thread.id}/update`, {
			pinned: !thread.pinned
		});
		if (!res.ok) return;

		thread.pinned = !thread.pinned;
		threads = threads;
	};

	onMount(() => {
		getThreads();
	});
</script>

<div>
	<form
		class="bg-white dark:bg-darkobject dark:text-darkmodeText shadow rounded p-4 flex items-end w-full gap-4 mb-6"
		on:submit|preventDefault={handleSearch}
	>
		<TextInput
			Class="w-4/5"
			onInput={() => (searched = false)}
			label={$_('Search')}
			bind:value={searchQuery}
		/>

		<Button
			Class={`w-8 h-8 ml-4 !p-1 flex justify-center items-center ${
				searched ? 'bg-blue-300' : 'bg-blue-600'
			}`}
			type="submit"
		>
			<Fa icon={faMagnifyingGlass} />
		</Button>
	</form>

	{#if threads.length === 0}
		<div
			class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 shadow-lg rounded-md mb-6 text-center"
		>
			{$_('There are currently no threads in this group')}
		</div>
	{/if}
	{#each threads as thread}
		<div class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 shadow-lg rounded-md mb-6">
			<div class="flex justify-between items-center">
				<button
					class="cursor-pointer hover:underline text-primary dark:text-secondary text-2xl text-left"
					on:click={() => goto(`${$page.params.groupId}/thread/${thread.id}`)}
					>{thread.title}</button
				>

				<div class="flex gap-3">
					<NotificationOptions
						type="group_thread"
						api={`group/thread/${thread.id}`}
						categories={['comment']}
						id={thread.id}
						labels={['comment']}
					/>
					{#if isAdmin || thread.pinned}
						<button class:cursor-pointer={isAdmin} on:click={() => pinThread(thread)}>
							<Fa
								size="1.2x"
								icon={faThumbTack}
								color={thread.pinned ? '#999' : '#CCC'}
								rotate={thread.pinned ? '0' : '45'}
							/>
						</button>
					{/if}
				</div>
			</div>
			{#if thread.description}
				<Description limit={500} description={thread.description} />
			{/if}

			<hr class="my-3" />

			<div class="flex justify-between align-middle">
				<div
					class="hover:bg-gray-100 dark:hover:bg-slate-500 cursor-pointer text-sm text-gray-600 dark:text-darkmodeText"
				>
					<a
						class="text-black dark:text-darkmodeText"
						href={`${$page.params.groupId}/thread/${thread.id}`}
					>
						<Fa class="inline" icon={faComment} />
						<span class="inline">{thread.total_comments} {'comments'}</span>
					</a>
				</div>
				<div>
					<div class="flex gap-1">
						{thread.score}
						<button
							class:text-primary={thread.user_vote === true}
							on:click={() => threadVote(thread, 'up')}
						>
							<Fa icon={faArrowUp} />
						</button>
						<button
							class:text-primary={thread.user_vote === false}
							on:click={() => threadVote(thread, 'down')}
						>
							<Fa icon={faArrowDown} />
						</button>
					</div>
				</div>
			</div>
		</div>
	{/each}
	<Pagination bind:prev bind:next bind:iterable={threads} />
</div>

<Poppup bind:poppup />

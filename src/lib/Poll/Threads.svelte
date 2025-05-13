<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import Pagination from '$lib/Generic/Pagination.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import { threads as threadsLimit } from '$lib/Generic/APILimits.json';
	import { _ } from 'svelte-i18n';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import ThreadThumbnail from './Thread.svelte';
	import type { Thread } from '$lib/Group/interface';
	import Select from '$lib/Generic/Select.svelte';

	export let isAdmin = true;

	let threads: Thread[] = [],
		prev = '',
		next = '',
		poppupState: poppup,
		searchQuery = '',
		searched = true,
		workGroups: any[] = [],
		selectedWorkGroupId: null | number = null;

	const getThreads = async () => {
		let url = `group/thread/list?group_ids=${$page.params.groupId}&limit=${threadsLimit}&order_by=pinned,created_at_desc`;
		if (searchQuery) {
			url += `&title__icontains=${searchQuery}`;
		}
		if (selectedWorkGroupId !== null) {
			url += `&work_group=${selectedWorkGroupId}`;
		}

		const { res, json } = await fetchRequest('GET', url);

		if (!res.ok) {
			poppupState = { message: 'Could not get threads', success: false };
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

	const handleWorkGroupChange = (e: Event) => {
		const select = e.target as HTMLSelectElement;
		selectedWorkGroupId = select.value === '' ? null : Number(select.value);
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
			poppupState = { message: 'Could not vote on thread', success: false };
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

	const getWorkGroupList = async () => {
		const { res, json } = await fetchRequest('GET', `group/${$page.params.groupId}/list`);

		if (!res.ok) {
			poppupState = { message: 'Failed to get workgroups', success: false };
			return;
		}

		workGroups = json.results;
	};

	onMount(() => {
		getThreads();
		getWorkGroupList();
	});
	
	$: workGroupLabels = ['All Work Groups', ...workGroups.map(wg => wg.name)];
	$: workGroupValues = [null, ...workGroups.map(wg => wg.id)];
</script>

<div>
	<form
		class="bg-white dark:bg-darkobject dark:text-darkmodeText shadow rounded p-4 flex flex-col md:flex-row items-end w-full gap-4 mb-6"
		on:submit|preventDefault={handleSearch}
	>
		<TextInput
			Class="w-full md:w-4/5"
			onInput={() => (searched = false)}
			label={$_('Search')}
			bind:value={searchQuery}
		/>

		<div class="w-full md:w-1/5">
			<Select
				label={$_('Filter by Work Group')}
				labels={workGroupLabels}
				values={workGroupValues}
				value={selectedWorkGroupId}
				onInput={handleWorkGroupChange}
				Class="w-full"
			/>
		</div>
	</form>

	{#if threads.length === 0}
		<div
			class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 shadow-lg rounded-md mb-6 text-center"
		>
			{#if selectedWorkGroupId !== null}
				{$_('There are currently no threads in this work group')}
			{:else}
				{$_('There are currently no threads in this group')}
			{/if}
		</div>
	{/if}
	{#each threads as thread}
		<ThreadThumbnail {thread} {isAdmin} />
	{/each}
	<Pagination bind:prev bind:next bind:iterable={threads} />
</div>

<Poppup bind:poppup={poppupState} />

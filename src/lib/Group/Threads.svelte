<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { Thread } from './interface';
	import Pagination from '$lib/Generic/Pagination.svelte';

	let threads: any[] = [],
	prev = "", next = ""

	const getThreads = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/thread/list?limit=2`,
			{}
		);

		next = json.next
		prev = json.previous

		threads = json.results;
	};

	onMount( () => {
		getThreads();
	});
</script>

<div>
	{#if threads.length === 0}
	<div class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 shadow-lg rounded-md mb-6 text-center">There are currently no threads in this group</div>
	{/if}
	{#each threads as thread}
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<div
			class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 shadow-lg rounded-md mb-6 cursor-pointer"
			on:click={() => window.location.href = `${$page.params.groupId}/thread/${thread.id}`}
			on:keydown
		>
			{thread.title}
		</div>
	{/each}
	<Pagination bind:prev bind:next bind:iterable={threads}/>
</div>

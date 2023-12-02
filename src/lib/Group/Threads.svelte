<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { Thread } from './interface';

	let threads: any[] = [];

	const getThreads = async (): Promise<any[]> => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/thread/list`,
			{}
		);
		return json.results;
	};

	onMount(async () => {
		threads = await getThreads();
	});
</script>

<div>
	{#each threads as thread}
		<div
			class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 shadow-lg rounded-md mb-6 cursor-pointer"
			on:click={() => window.location.href = `${$page.params.groupId}/thread/${thread.id}`}
			on:keydown
		>
			{thread.title}
		</div>
	{/each}
</div>

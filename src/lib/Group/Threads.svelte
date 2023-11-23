<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';

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
		<div class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 shadow-lg rounded-md mb-6">
			{thread.title}
		</div>
	{/each}
</div>

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import PollThumbnail from './PollThumbnail.svelte';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';

	export let Class = '';
	let polls: any[] = [];

	const getPolls = async () => {
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/poll/list?limit=100`);
		polls = json.results;
	};

	onMount(() => {
		getPolls();
	});
</script>

<div class={`flex flex-col gap-6 ${Class}`}>
	<!-- <h1 class="text-3xl text-left">Flow</h1> -->
	{#each polls as poll}
		<PollThumbnail {poll}/>
	{/each}
</div>

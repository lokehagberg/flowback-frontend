<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import PollThumbnail from './PollThumbnail.svelte';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	export let Class = '';
	let polls: any[] = [];

	const getPolls = async () => {
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/poll/list?limit=100`);
		polls = json.results.reverse();
	};

	onMount(() => {
		getPolls();
	});
</script>

<div class={`flex flex-col gap-6 ${Class}`}>
	<!-- <h1 class="text-3xl text-left">Flow</h1> -->
	{#if polls.length > 0}
	{#each polls as poll}
		<PollThumbnail {poll}/>
	{/each}
	{:else}
	<div class="bg-white rounded shadow p-8">{$_("No polls currently here")}</div>
	{/if}
</div>

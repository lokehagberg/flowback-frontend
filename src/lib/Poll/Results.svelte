<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { proposal } from '$lib/typescriptexperiments';
	import { onMount } from 'svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import Statistics from './Statistics.svelte';
	import { _ } from 'svelte-i18n';

	let proposals: any[] = [],
		votes: number[] = [],
		labels: string[] = [];

	//1 for ranking, 3 for scheduled
	export let pollType = 1;

	const getProposals = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposals?limit=100`
		);

		if (pollType === 1) proposals = json.results;
		else if (pollType === 3)
			proposals = [
				{
					id: json.results[0].id,
					title: formatDate(json.results[0].start_date),
					description: formatDate(json.results[0].end_date)
				}
			];

		votes = proposals.map((proposal) => proposal.score) || [];
		labels = proposals.map((proposal) => proposal.title) || [];
        console.log(labels)
	};

	onMount(() => {
		getProposals();
	});
</script>

<div class="border border-gray- p-4 rounded">
	{#if pollType === 1}
		<Statistics bind:votes bind:labels />
	{/if}
	{#each proposals as proposal}
		<div class="border p-4 mt-4">
			<h1 class="text-xl">{pollType === 3 ? $_('Start') + ':' : ''} {proposal.title}</h1>
			<div>{pollType === 3 ? $_('End') + ':' : ''} {proposal.description}</div>
			<div class="text-xl font-bold">{$_('Points')}: {proposal.score || '0'}</div>
		</div>
	{/each}
</div>

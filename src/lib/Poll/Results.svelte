<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import Statistics from './Statistics.svelte';
	import { _ } from 'svelte-i18n';
	import { poll } from 'ethers/lib/utils';

	let proposals: any[] = [],
		votes: number[] = [],
		labels: string[] = [];

	//4 for score voting, 3 for date
	export let pollType = 1;

	const getProposals = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposals?limit=1000`
		);

		if (pollType === 4) proposals = json.results;
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
	};

	onMount(() => {
		getProposals();
	});
</script>

<div class="border border-gray- p-4 rounded">
	<h1 class="text-4xl mb-6">{$_('Results')}</h1>
	{#if pollType === 4}
		<Statistics bind:votes bind:labels />
		{#each proposals as proposal}
			<div class="border p-4 mt-4">
				<h1 class="text-xl">{proposal.title}</h1>
				<div>{proposal.description}</div>
				<!-- {@debug proposal} -->
				<b class="text-xl font-bold">{$_('Points')}: {proposal.score || '0'}</b>
			</div>
		{/each}
	{:else if pollType === 3}
	<div>
		Results in Group Schedule
	</div>
	{/if}
</div>

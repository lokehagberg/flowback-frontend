<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import Statistics from './Statistics.svelte';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faStar } from '@fortawesome/free-solid-svg-icons';

	let votes: number[] = [],
		labels: string[] = [];

	//4 for score voting, 3 for date
	export let pollType = 1,
		proposals: any[] = [];

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

<div class="w-full">
	<span class="text-primary font-bold text-xl text-center block">{$_('Results')}</span>
	{#if pollType === 4}
		<Statistics bind:votes bind:labels />
		{#each proposals as proposal, i}
			<div class="border-gray-300 border-b-2 mt-3 pb-1">
				<span class="text-primary font-bold flex items-center gap-1"
					>{#if i === 0} <Fa icon={faStar} color="orange" /> {/if}
					{proposal.title}</span
				>
				<div>{proposal.description}</div>
				<!-- {@debug proposal} -->
				<span class="block text-right"
					><span class="text-primary font-bold">{$_('Points')}:</span> {proposal.score || '0'}</span
				>
			</div>
		{/each}
	{:else if pollType === 3}
		<div>Results in Group Schedule</div>
	{/if}
</div>

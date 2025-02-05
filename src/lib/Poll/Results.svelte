<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import Statistics from './Statistics.svelte';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faStar } from '@fortawesome/free-solid-svg-icons';
	import Description from './Description.svelte';

	let votes: number[] = [],
		labels: string[] = [];

	//4 for score voting, 3 for date
	export let pollType = 1,
		proposals: any[] = [];

	const getProposals = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposals?limit=1000&order_by=score_desc`
		);
		console.log('WHAAAATTT', json, pollType);

		if (pollType === 4) proposals = json.results;
		else if (pollType === 3)
			//Only one proposal wins in date poll
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
	<span class="text-primary dark:text-secondary font-semibold text-xl text-center block">{$_('Results')}</span>

	{#if pollType === 4}
		<!-- If the winner has atleast one point, display statistics (otherwise it looks empty) -->
		{#if proposals[0]?.score > 0}
			<Statistics bind:votes bind:labels />
		{/if}
		{#each proposals as proposal, i}
			<div class="border-gray-300 border-b-2 mt-3 pb-1">
				<span class="text-primary dark:text-secondary font-semibold flex items-center gap-1 break-all"
					>{#if i === 0} <Fa icon={faStar} color="orange" /> {/if}
					{proposal.title}</span
				>
				<Description description={proposal.description} limit={50} />
				<span class="block text-right"
					><span class="text-primary dark:text-secondary font-semibold">{$_('Points')}:</span>
					{proposal.score || '0'}</span
				>
			</div>
		{/each}
	{:else if pollType === 3}
		<div>{$_('Results in Group Schedule')}</div>
	{/if}
</div>

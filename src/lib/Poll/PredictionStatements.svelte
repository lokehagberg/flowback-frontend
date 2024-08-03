<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Phase, poll, proposal } from './interface';
	import { page } from '$app/stores';
	import type { PredictionStatement } from './PredictionMarket/interfaces';
	import Prediction from './PredictionMarket/Prediction.svelte';

	export let selectedProposal: proposal, phase: Phase, poll: poll;

	let predictions: PredictionStatement[] = [];

	const getPredictionStatements = async (selectedProposal: proposal) => {
		// loading = true;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/prediction/statement/list?poll_id=${$page.params.pollId}
            &proposals=${selectedProposal.id}`
		);
		// loading = false;
		predictions = json.results;
	};

	$: if (selectedProposal) getPredictionStatements(selectedProposal);
</script>

<div>
	{#each predictions as prediction}
		{#if phase === 'prediction_bet'}
			<Prediction bind:phase bind:poll bind:prediction />
		{:else}
			<div class="flex justify-between">
				{prediction.description}
				<span
					>Combined bet:
					{#if prediction.combined_bet}
						{prediction.combined_bet}
					{:else}
						none
					{/if}
				</span>
			</div>
		{/if}
	{/each}
</div>

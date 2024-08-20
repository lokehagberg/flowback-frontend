<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Phase, poll, proposal } from './interface';
	import { page } from '$app/stores';
	import type { PredictionStatement } from './PredictionMarket/interfaces';
	import Prediction from './PredictionMarket/Prediction.svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';

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

<div class="border-t-2">
	{#each predictions as prediction}
		<div class="border-b-2 flex flex-col pt-3"
		class:select-none={phase === 'prediction_bet'}
		>
			<span class="text-primary font-semibold">{prediction.title}</span>
			<span class="">{prediction.description}</span>
			<span class="text-sm text-gray-500">{formatDate(prediction.end_date)}</span>
			{#if phase === 'delegate_vote' || phase === 'vote'}
				<span class="text-sm text-right"
					>Bet:
					{#if prediction.combined_bet}
						{prediction.combined_bet}
					{:else}
						none
					{/if}
				</span>
			{:else if phase === 'prediction_bet' || phase === "result" || phase === 'prediction_vote'}
				<Prediction bind:phase bind:poll bind:prediction />
			{/if}
		</div>
	{/each}
</div>

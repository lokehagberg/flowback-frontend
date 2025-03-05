<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Phase, poll, proposal } from './interface';
	import { page } from '$app/stores';
	import type { PredictionStatement } from './PredictionMarket/interfaces';
	import Prediction from './PredictionMarket/Prediction.svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import { _ } from 'svelte-i18n';
	import Description from './Description.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { onMount } from 'svelte';

	export let selectedProposal: proposal, phase: Phase, poll: poll;

	let predictions: PredictionStatement[] = [],
		loading = false;

	const getPredictionStatements = async (selectedProposal: proposal) => {
		loading = true;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/prediction/statement/list?poll_id=${$page.params.pollId}
            &proposals=${selectedProposal.id}`
		);
		loading = false;
		predictions = json.results;
		console.log(predictions, 'predictions');
		
	};

	$: if (selectedProposal) getPredictionStatements(selectedProposal);
</script>

<Loader bind:loading>
	<div class="border-t-2">
		<div class="text-gray-500 text-sm pt-3 font-semibold">{$_('Predictions')}({predictions.length})</div>
		{#key selectedProposal}
		{#each predictions as prediction}
			<div
				class="border-b-2 flex flex-col break-all py-2 gap-1"
				class:select-none={phase === 'prediction_bet'}
			>
				<span class="text-primary dark:text-secondary font-semibold">{prediction.title}</span>
				<span class="text-sm text-gray-500">{formatDate(prediction.end_date)}</span>
				{#if prediction.description}
					<Description description={prediction.description} limit={130} />
				{/if}
				{#if phase === 'delegate_vote' || phase === 'vote'}
					<span class="text-sm text-right"
						>{$_('Bet')}:
						{#if prediction.combined_bet}
							{prediction.combined_bet}
						{:else}
							{$_('none')}
						{/if}
					</span>
				{:else if phase === 'prediction_bet' || phase === 'result' || phase === 'prediction_vote'}
					<Prediction Class="mt-4" bind:phase bind:poll bind:prediction />
				{/if}
			</div>
		{/each}
		{/key}
	</div>
</Loader>

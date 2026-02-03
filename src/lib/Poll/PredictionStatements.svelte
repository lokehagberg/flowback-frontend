<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Phase, poll, proposal } from './interface';
	import { page } from '$app/stores';
	import type { PredictionStatement } from './PredictionMarket/interfaces';
	import Prediction from './PredictionMarket/Prediction.svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import { _ } from 'svelte-i18n';
	import NewDescription from './NewDescription.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { onMount } from 'svelte';
	import { proposals as proposalsLimit } from '../Generic/APILimits.json';

	export let selectedProposal: proposal | null = null,
		phase: Phase,
		poll: poll,
		proposals: proposal[] = [],
		getPollData = () => {};

	let predictions: PredictionStatement[] = [],
		loading = false;

	const getPredictionStatements = async (selectedProposal: proposal | null) => {
		if (!selectedProposal) return;

		loading = true;

		if (poll.status_prediction === 0) getPollData();

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/prediction/statement/list?poll_id=${$page.params.pollId}${
				selectedProposal ? `&proposals=${selectedProposal.id}` : ''
			}`
		);

		loading = false;
		predictions = json?.results;
	};

	const getProposals = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposals?limit=${proposalsLimit}`
		);

		if (!res.ok) return;

		proposals = json?.results;
	};

	$: if (selectedProposal) {
		getPredictionStatements(selectedProposal);
	}

	onMount(async () => {
		await getPredictionStatements(selectedProposal);

		if (poll.status === 1) {
			await getProposals();
			selectedProposal = proposals.sort((proposal) => proposal.score)[0];
		}
	});
</script>

<Loader bind:loading>
	<!-- In results/prediction_vote phase, "selected proposal" is always set as the winning proposal. If no such is found, don't display any predictions  -->
	{#if (phase === 'prediction_vote' && selectedProposal && selectedProposal?.score > 0) || phase !== 'prediction_vote'}
		<div class={phase === 'prediction_vote' ? '' : 'border-t-2'}>
			<div
				class={`font-semibold ${
					phase === 'prediction_vote' ? ' text-xl mb-4 text-primary' : ' text-gray-500 text-sm pt-3'
				}`}
			>
				{$_('Consequences')} ({predictions?.length || 0})
			</div>

			{#if predictions?.length > 0}
				{#each predictions as prediction}
					<div
						class="elipsis border-b-2 flex flex-col break-words py-2 gap-1"
						class:select-none={phase === 'prediction_bet'}
					>
						<span class="text-primary dark:text-secondary font-semibold">{prediction.title}</span>
						<span class="text-sm text-gray-500">{formatDate(prediction.end_date)}</span>

						{#if prediction.description}
							<NewDescription description={prediction.description} limit={2} lengthLimit={110} />
						{/if}
						{#if phase === 'delegate_vote' || phase === 'vote'}
							<span class="text-sm text-right"
								>{$_('Probability')}:
								{#if prediction?.combined_bet !== null}
									{(prediction.combined_bet * 100).toFixed(0)}%
								{:else if poll.status_prediction !== 1}
									{$_('Calculating')}
								{:else}
									{$_('None')}
								{/if}
							</span>
						{:else if phase === 'prediction_bet' || phase === 'result' || phase === 'prediction_vote'}
							<Prediction Class="mt-4" bind:phase bind:poll bind:prediction />
						{/if}
					</div>
				{/each}
			{/if}
		</div>
	{/if}
</Loader>

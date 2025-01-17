<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import type { Phase, poll } from '../interface';
	import type { PredictionStatement } from './interfaces';
	import { faCheck } from '@fortawesome/free-solid-svg-icons/faCheck';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import Modal from '$lib/Generic/Modal.svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import { createPredictionBet as createPredictionBetBlockchain } from '$lib/Blockchain_v1_Ethereum/javascript/predictionsBlockchain';
	import VotingSlider from '../VotingSlider.svelte';
	import { env } from '$env/dynamic/public';
	import { elipsis } from '$lib/Generic/GenericFunctions';

	export let prediction: PredictionStatement,
		loading: boolean = false,
		score: null | number = null,
		phase: Phase,
		poll: poll;

	let showPoppup = false,
		showDetails = false,
		poppup: poppup;

	const getPredictionBet = async () => {
		// if (!score) return;
		loading = true;
		console.log(prediction.id, prediction.title, 'prediction.id');
		
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/prediction/bet/list?prediction_statement_id=${prediction.id}`
		);

		loading = false;
		if (!res.ok) showPoppup = true;
		else {
			const previousBet = json.results.find(
				(result: any) => result.created_by.user.id.toString() === localStorage.getItem('userId')
			);

			if (previousBet !== null && previousBet !== undefined) score = previousBet.score;
			else score = null;
		}
	};

	const predictionBetCreate = async (score: string | number) => {
		// if (!score) return;
		loading = true;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/bet/create`,
			{
				score: `${score}`
			}
		);
		loading = false;

		if (!res.ok) {
			poppup = { message: 'Betting failed', success: false };
			return;
		}

		poppup = { message: 'Successfully placed bet', success: true, show: true };
	};

	const predictionBetUpdate = async (score: string | number) => {
		if (score === null) return;
		loading = true;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/bet/update`,
			{
				score: `${score}`
			}
		);
		loading = false;

		if (!res.ok) {
			poppup = { message: 'Betting failed', success: false };
			return;
		}

		poppup = { message: 'Successfully placed bet', success: true, show: true };
	};

	const predictionBetDelete = async () => {
		loading = true;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/bet/delete`
		);

		loading = false;

		if (!res.ok) {
			poppup = { message: 'Betting failed to be deleted', success: false };
			return;
		}
		poppup = { message: 'Successfully placed bet', success: true };
	};

	const createEvaluation = async (vote: boolean) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/statement/vote/create`,
			{ vote }
		);

		if (!res.ok) {
			poppup = { message: 'Evaluation failed', success: false };
			return;
		}

		poppup = { message: 'Successfully evaluated prediction', success: true };
		prediction.user_prediction_statement_vote = vote;
	};

	const deleteEvaluation = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/bet/delete`
		);

		if (!res.ok) {
			poppup = { message: 'Something went wrong', success: false };
			return;
		}

		prediction.user_prediction_statement_vote = null;
	};

	const changeEvaluation = async (vote: boolean) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/statement/vote/update`,
			{
				vote
			}
		);

		if (!res.ok) {
			poppup = { message: 'Something went wrong', success: false };
			return;
		}

		poppup = { message: 'Successfully evaluated prediction', success: true };

		prediction.user_prediction_statement_vote = vote;
	};

	//TODO: Fix AI integration
	const getAIPredictionBets = async () => {
		const { res, json } = await fetchRequest('POST', 'ai/prediction_bets', {
			proposals: 'Eat soup',
			predictions: "You'll get fed\n You'll get food poison"
		});
	};

	const handleChangeBetScore = async (newScore: number) => {
		if (newScore === null) predictionBetDelete();
		else if (score === null) {
			predictionBetCreate(newScore);
		} else predictionBetUpdate(newScore);

		if (
			env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE' &&
			poll.blockchain_id &&
			prediction.blockchain_id &&
			score
		)
			createPredictionBetBlockchain(poll.blockchain_id, prediction.blockchain_id, score);

		score = Number(newScore);
	};

	onMount(() => {
		getPredictionBet();
	});
</script>

<div>
	{#if prediction.description}
		<span class="hover:underline cursor-pointer overflow-hidden">
			{elipsis(prediction.description)}</span
		>
	{/if}
	<span>{$_('Due Date')}: {formatDate(prediction.end_date)}</span>

	{#if phase === 'prediction_bet'}
		<VotingSlider onSelection={handleChangeBetScore} lineWidth={50} bind:score />
	{/if}

	{#if phase === 'result' || phase === 'prediction_vote'}
		<div class="flex justify-end mb-3">
			<Button
				action={() =>
					prediction.user_prediction_statement_vote === null
						? createEvaluation(true)
						: prediction.user_prediction_statement_vote === true
						? deleteEvaluation()
						: changeEvaluation(true)}
				Class={`w-12 px-4 py-1 border-2 ${
					prediction.user_prediction_statement_vote === true
						? 'bg-green-600 text-white border-green-600'
						: 'hover:bg-green-100 border-green-600 text-green-800'
				}`}
			>
				<Fa
					icon={faCheck}
					class={`${
						prediction.user_prediction_statement_vote === true ? 'text-white' : 'text-green-700'
					}`}
				/>
			</Button>
			<Button
				action={() =>
					prediction.user_prediction_statement_vote === null
						? createEvaluation(false)
						: prediction.user_prediction_statement_vote === false
						? deleteEvaluation()
						: changeEvaluation(false)}
				Class={`w-12 px-4 py-1 ml-2 border-2 ${
					prediction.user_prediction_statement_vote === false
						? 'bg-red-700 text-white border-red-700'
						: 'hover:bg-red-100 border-red-500 text-red-600'
				}`}
			>
				<Fa
					icon={faX}
					class={`${
						prediction.user_prediction_statement_vote === false ? 'text-white' : 'text-red-600'
					}`}
				/>
			</Button>
		</div>
	{/if}
</div>

<Modal bind:open={showDetails}>
	<div slot="body">
		<div class="break-all">{prediction.description}</div>
		<ul>
			{#each prediction.segments as proposal}
				<li>{proposal.proposal_title} is {proposal.is_true ? 'Implemented' : 'Not Implemented'}</li>
			{/each}
		</ul>
		<div>{$_('Deadline')}: {formatDate(prediction.end_date.toString())}</div>
		{#if prediction.combined_bet}
			<div>{$_('Aggregated Bet')}: {prediction.combined_bet}</div>
		{/if}
	</div>
</Modal>

<Poppup bind:poppup />

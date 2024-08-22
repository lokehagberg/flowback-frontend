<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Select from '$lib/Generic/Select.svelte';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
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
	import { createPredictionBet as createPredictionBetBlockchain } from '$lib/Blockchain/javascript/predictionsBlockchain';
	import VotingSlider from '../VotingSlider.svelte';
	import { env } from "$env/dynamic/public";

	export let prediction: PredictionStatement,
		loading: boolean = false,
		score: null | number = null,
		phase: Phase,
		poll: poll;

	let showPoppup = false,
		showDetails = false,
		poppup: poppup;

	onMount(() => {
		getPredictionBet();
	});

	const getPredictionBet = async () => {
		// if (!score) return;
		loading = true;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/prediction/bet/list?prediction_statement_id=${prediction.id}`
		);

		loading = false;
		if (!res.ok) showPoppup = true;
		else {
			const previousBet = json.results.find(
				(result: any) => result.created_by.id.toString() === localStorage.getItem('userId')
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

		poppup = { message: 'Successfully betted', success: true, show: true };
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

		poppup = { message: 'Successfully updated bet', success: true, show: true };
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
		poppup = { message: 'Successfully updated bet', success: true };
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
</script>

<div class="">
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	<!-- <span
		on:click={() => (showDetails = true)}
		on:keydown
		class="hover:underline cursor-pointer overflow-hidden"
	>
		{prediction.description}</span
	>
	<span>{formatDate(prediction.end_date)}</span> -->
	{#if phase === 'prediction_bet'}
		<VotingSlider onSelection={handleChangeBetScore} lineWidth={50} />
		<!-- <Button action={getAIPredictionBets}>Let AI decide</Button> -->
		<!-- <Select
			labels={['Not selected', '0', '20', '40', '60', '80', '100']}
			values={[null, 0, 1, 2, 3, 4, 5]}
			bind:value={score}
			onInput={
				
			}
		/> -->
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
				Class={`px-4 py-1 ${
					prediction.user_prediction_statement_vote === true && 'brightness-200'
				}`}
			>
				<Fa icon={faCheck} />
			</Button>
			<Button
				action={() =>
					prediction.user_prediction_statement_vote === null
						? createEvaluation(false)
						: prediction.user_prediction_statement_vote === false
						? deleteEvaluation()
						: changeEvaluation(false)}
				Class={`px-4 py-1 ml-2 ${
					prediction.user_prediction_statement_vote === false && 'brightness-200'
				}`}
			>
				<Fa icon={faX} />
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
		<!-- {@debug prediction} -->
		<div>Deadline: {formatDate(prediction.end_date.toString())}</div>
		{#if prediction.combined_bet}
			<div>Aggregated Bet: {prediction.combined_bet}</div>
		{/if}
	</div>
</Modal>

<!-- <SuccessPoppup bind:show={showPoppup} message={'Something went wrong'} /> -->
<Poppup bind:poppup />

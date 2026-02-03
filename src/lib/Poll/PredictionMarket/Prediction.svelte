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
	import { onMount } from 'svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import VotingSlider from '../VotingSlider.svelte';
	import { env } from '$env/dynamic/public';

	export let prediction: PredictionStatement,
		loading: boolean = false,
		phase: Phase,
		poll: poll,
		Class = '';

	let score: null | number = null,
		showDetails = false;

	function hasEndDatePassed(): boolean {
		const currentDateTime = new Date();
		const endDateTime = new Date(prediction.end_date);
		return currentDateTime >= endDateTime;
	}

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
			ErrorHandlerStore.set({
				message: 'Failed to send probability',
				success: false
			});
			return;
		}

		ErrorHandlerStore.set({
			message: 'Probability successfully sent',
			success: true,
			show: true
		});
	};

	const predictionBetDelete = async () => {
		loading = true;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/bet/delete`
		);

		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to change probability',
				success: false
			});
			return;
		}

		ErrorHandlerStore.set({
			message: 'Probability successfully sent',
			success: true
		});
	};

	const createEvaluation = async (vote: boolean) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/statement/vote/create`,
			{ vote }
		);

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Evaluation failed', success: false });
			return;
		}

		ErrorHandlerStore.set({
			message: 'Successfully evaluated consequence',
			success: true
		});
		prediction.user_prediction_statement_vote = vote;
	};

	const deleteEvaluation = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/statement/vote/delete`
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Something went wrong',
				success: false
			});
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
			ErrorHandlerStore.set({
				message: 'Something went wrong',
				success: false
			});
			return;
		}

		ErrorHandlerStore.set({
			message: 'Successfully evaluated consequence',
			success: true
		});

		prediction.user_prediction_statement_vote = vote;
	};

	//TODO: Fix AI integration
	const getAIPredictionBets = async () => {
		const { res, json } = await fetchRequest('POST', 'ai/prediction_bets', {
			proposals: prediction.segments.map((segment) => segment.proposal_title),
			predictions: prediction.title
		});
	};

	const handleChangeBetScore = async (newScore: number | null) => {
		if (newScore === null || newScore === 2.5) predictionBetDelete();
		else predictionBetUpdate(newScore);

		if (
			env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE' &&
			poll.blockchain_id &&
			prediction.blockchain_id &&
			score
		)
			// createPredictionBetBlockchain(poll.blockchain_id, prediction.blockchain_id, score);

			score = Number(newScore);
	};

	$: buttonsEnabled = hasEndDatePassed();

	onMount(() => {
		buttonsEnabled = hasEndDatePassed();

		const interval = setInterval(() => {
			buttonsEnabled = hasEndDatePassed();
		}, 60000);

		return () => clearInterval(interval);
	});
</script>

<div class={Class}>
	<!-- PHASE 4: PREDICTION BETTING -->
	{#if phase === 'prediction_bet'}
		<VotingSlider
			onSelection={handleChangeBetScore}
			lineWidth={50}
			score={prediction.user_prediction_bet}
			bind:phase
		/>
		{#if env.PUBLIC_FLOWBACK_AI_MODULE === 'TRUE'}
			<Button onClick={getAIPredictionBets}>
				{$_('Get AI Consequence Probabilities')}
			</Button>
		{/if}
	{/if}

	<!-- PHASE 7: RESULTS AND EVALUATION -->

	{#if phase === 'result' || phase === 'prediction_vote'}
		<div class="flex justify-end mb-3">
			<Button
				onClick={() =>
					prediction.user_prediction_statement_vote === null
						? createEvaluation(true)
						: prediction.user_prediction_statement_vote === true
							? deleteEvaluation()
							: changeEvaluation(true)}
				Class={`w-12 px-4 py-1 border-2 
				${!buttonsEnabled ? 'disabled hover:!bg-transparent' : ''}
				${
					prediction.user_prediction_statement_vote === true
						? 'bg-green-600 text-white border-green-600'
						: 'hover:bg-green-100 border-green-600 text-green-800'
				}`}
			>
				<Fa
					icon={faCheck}
					class={`${
						prediction.user_prediction_statement_vote === true
							? 'text-white'
							: 'text-green-700'
					} ${!buttonsEnabled ? '!text-gray-300' : ''}`}
				/>
			</Button>
			<Button
				onClick={() =>
					prediction.user_prediction_statement_vote === null
						? createEvaluation(false)
						: prediction.user_prediction_statement_vote === false
							? deleteEvaluation()
							: changeEvaluation(false)}
				Class={`w-12 px-4 py-1 ml-2 border-2 
				${!buttonsEnabled ? 'disabled hover:!bg-transparent' : ''}
				${
					prediction.user_prediction_statement_vote === false
						? 'bg-red-700 text-white border-red-700'
						: 'hover:bg-red-100 border-red-500 text-red-600'
				}`}
			>
				<Fa
					icon={faX}
					class={`${
						prediction.user_prediction_statement_vote === false
							? 'text-white'
							: 'text-red-600'
					} ${!buttonsEnabled ? '!text-gray-300' : ''}`}
				/>
			</Button>
		</div>
	{/if}
</div>

<Modal bind:open={showDetails}>
	<div slot="body">
		<div class="break-words whitespace-pre-wrap max-w-[300px]">
			{prediction.description}
		</div>
		<ul>
			{#each prediction.segments as proposal}
				<li>
					{proposal.proposal_title} is {proposal.is_true
						? 'Implemented'
						: 'Not Implemented'}
				</li>
			{/each}
		</ul>
		<div>{$_('Deadline')}: {formatDate(prediction.end_date.toString())}</div>
		{#if prediction.combined_bet}
			<div>{$_('Aggregated Bet')}: {prediction.combined_bet}</div>
		{/if}
	</div>
</Modal>

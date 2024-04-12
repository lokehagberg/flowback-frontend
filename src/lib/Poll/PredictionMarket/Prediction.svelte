<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Phase } from '../interface';
	import type { PredictionStatement } from './interfaces';
	import { faCheck } from '@fortawesome/free-solid-svg-icons/faCheck';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import Modal from '$lib/Generic/Modal.svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { userGroupInfo } from '$lib/Group/interface';
	import { poll } from 'ethers/lib/utils';

	export let prediction: PredictionStatement, loading: boolean, score: null | number, phase: Phase;

	let showPoppup = false,
		showDetails = false;

	onMount(() => {
		getPredictionBet();
	});

	const getPredictionBet = async () => {
		loading = true;

		if (!score) return;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/prediction/bet/list?prediction_statement_id=${prediction.id}`
		);

		console.log(json.results);

		if (!res.ok) showPoppup = true;
		else {
			const previousBet = json.results.find(
				(result: any) => result.created_by.id.toString() === localStorage.getItem('userId')
			);

			if (previousBet !== null && previousBet !== undefined) score = previousBet.score;
			else score = null;
		}
	};

	const predictionBetCreate = async (score: string) => {
		loading = true;

		if (!score) return;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/bet/create`,
			{
				score
			}
		);
		loading = false;

		if (!res.ok) showPoppup = true;
	};

	const predictionBetUpdate = async (score: string) => {
		loading = true;

		if (!score) return;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/bet/update`,
			{
				score
			}
		);
		loading = false;

		if (!res.ok) showPoppup = true;
	};

	const predictionBetDelete = async () => {
		loading = true;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/bet/delete`
		);

		loading = false;

		if (!res.ok) return;
	};

	const createEvaluation = async (vote: boolean) => {
		loading = true;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/statement/vote/create`,
			{ vote }
		);

		loading = false;
		if (!res.ok) {
			showPoppup = true;
			return;
		}

		prediction.user_prediction_statement_vote = vote;
	};

	const deleteEvaluation = async () => {
		loading = true;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/bet/delete`
		);
		loading = false;

		if (!res.ok) {
			showPoppup = true;
			return;
		}

		prediction.user_prediction_statement_vote = null;
	};

	const changeEvaluation = async (vote: boolean) => {
		loading = true;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${prediction.id}/statement/vote/update`,
			{
				vote
			}
		);

		loading = false;
		if (!res.ok) {
			showPoppup = true;
			return;
		}

		prediction.user_prediction_statement_vote = vote;
	};

	const getAIPredictionBets = async () => {
		const { res, json } = await fetchRequest('POST', 'ai/prediction_bets', {
			proposals: 'Eat soup',
			predictions: "You'll get full\n You'll get food poison"
		});
	};
</script>

<div class="flex justify-between">
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	<span on:click={() => (showDetails = true)} on:keydown class="hover:underline cursor-pointer overflow-scroll">
		{prediction.description}</span
	>
	{#if phase === 'prediction-betting'}
		<Button action={getAIPredictionBets}>Let AI decide</Button>
		<Select
			labels={['Not selected', '0', '20', '40', '60', '80', '100']}
			values={[null, 0, 1, 2, 3, 4, 5]}
			bind:value={score}
			onInput={async (e) => {
				//@ts-ignore
				const newScore = e?.target?.value;

				console.log(newScore);
				if (!newScore) predictionBetDelete();
				else if (score === null) {
					predictionBetCreate(newScore);
				} else predictionBetUpdate(newScore);

				score = Number(newScore);
				// await predictionBetDelete();

				// if (selectedScore !== null) {
				// 	score = Number(selectedScore);
				// 	predictionBetCreate();
				// }
			}}
		/>
	{/if}
	{#if phase === 'results' || phase === 'prediction-voting'}
		<div class="flex">
			<Button
				action={() =>
					prediction.user_prediction_statement_vote === null
						? createEvaluation(true)
						: prediction.user_prediction_statement_vote === true
						? deleteEvaluation()
						: changeEvaluation(true)}
				Class={`${prediction.user_prediction_statement_vote === true && 'brightness-200'}`}
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
				Class={`${prediction.user_prediction_statement_vote === false && 'brightness-200'}`}
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
		<div>End date: {formatDate(prediction.end_date.toString())}</div>
		<div>Aggregated Bet: {prediction.combined_bet}</div>
	</div>
</Modal>

<SuccessPoppup bind:show={showPoppup} message={'Something went wrong'} />

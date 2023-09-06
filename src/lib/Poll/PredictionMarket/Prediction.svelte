<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Phase } from '../interface';
	import type { PredictionStatement } from './interfaces';
	import { faCheck } from '@fortawesome/free-solid-svg-icons/faCheck';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';

	export let prediction: PredictionStatement, loading: boolean, score: null | number, phase: Phase;

	let showPoppup = false;

	const predictionBetCreate = async () => {
		console.log(score, 'SCOOOORE');
		loading = true;

		if (!score) return;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${prediction.id}/prediction/create`,
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
			`group/poll/${prediction.prediction_statement_id}/prediction/delete`
		);

		if (!res.ok) showPoppup = true;
		loading = false;
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
			`group/poll/prediction/statement/vote/${prediction.user_prediction_statement_vote_id}/delete`
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
			`group/poll/prediction/statement/vote/${prediction.user_prediction_statement_vote_id}/update`,
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
</script>

<div class="flex justify-between">
	<span> {prediction.description}</span>
	{#if phase === 'prediction'}
		<Select
			labels={['Not selected', '0', '20', '40', '60', '80', '100']}
			values={[null, 0, 1, 2, 3, 4, 5]}
			onInput={async (e) => {
				//@ts-ignore
				const selectedScore = e?.target?.value;
				await predictionBetDelete();

				if (selectedScore !== null) predictionBetCreate();
			}}
		/>
	{/if}
	{#if phase === 'end'}
		<div class="flex">
			<Button
				action={() =>
					prediction.user_prediction_statement_vote === null
						? createEvaluation(true)
						: prediction.user_prediction_statement_vote === true
						? deleteEvaluation()
						: changeEvaluation(false)}
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

<SuccessPoppup bind:show={showPoppup} message={'Something went wrong'} />

<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import Loader from '$lib/Generic/Loader.svelte';
	import Prediction from './Prediction.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import DateInput from 'date-picker-svelte/DateInput.svelte';
	import type { Phase, proposal } from '../interface';
	import Question from '$lib/Generic/Question.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import { maxDatePickerYear } from '$lib/Generic/DateFormatter';
	// import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	// import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	// import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import type { PredictionBet, PredictionStatement } from './interfaces';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';

	let loading = false,
		predictions: PredictionStatement[] = [],
		addingPrediction = false,
		prediction_statement_id = 0,
		newPredictionStatement: {
			description?: string;
			end_date?: Date;
			segments: {
				proposal_id: number;
				is_true: boolean;
			}[];
		} = { segments: [] },
		// statusMessage: StatusMessageInfo,
		bets: PredictionBet[] = [],
		show = false,
		message = '',
		resetsOfValues = 0;

	export let proposals: proposal[], phase: Phase;

	const getPredictionStatements = async () => {
		loading = true;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/prediction/statement/list?poll_id=${$page.params.pollId}`
		);
		loading = false;
		predictions = json.results;
	};

	const getPredictionBets = async () => {
		loading = true;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/prediction/statement/list`
		);

		loading = false;
		bets = json.results;
	};

	const createPredictionStatement = async () => {
		loading = true;
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/prediction/statement/create`,
			newPredictionStatement
		);
		loading = false;
		show = true;

		if (!res.ok) {
			message = json.detail[0];
			return;
		}

		newPredictionStatement = { segments: [] };
		resetsOfValues++;
		addingPrediction = false;
		message = 'Successfully created prediction statement';

		getPredictionStatements();
	};

	const deletePredictionStatement = async (id: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${id}/statement/delete`
		);
	};

	const addPrediction = async () => {
		loading = true;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${prediction_statement_id}/prediction/create`,
			{}
		);
		loading = false;
	};

	const getAIpredictionStatement = async () => {
		console.log(proposals[0])
		const { res, json } = await fetchRequest('POST', 'ai/prediction_statement', {
			prompt: proposals[0].title
		});
	};

	onMount(() => {
		getPredictionStatements();
		getPredictionBets();
	});
</script>

<Loader bind:loading>
	<h2>{$_('Prediction Market')}</h2>
	<ul class="mb-4">
		{#each predictions as prediction}
			<li><Prediction {prediction} bind:loading score={2} bind:phase /></li>
		{/each}
	</ul>

	{#if phase === 'prediction-statement'}
		<Button action={() => (addingPrediction = true)}>{$_('Add Prediction')}</Button>
	{/if}

	{#if predictions.length === 0}
		<div class="mt-5">{$_('There are currently no predictions')}</div>
	{/if}
</Loader>

<!-- Actives whenever a prediction statement is being added -->
<Modal bind:open={addingPrediction}>
	<div slot="header">{$_('Add Prediction')}</div>
	<form slot="body" on:submit={createPredictionStatement}>
		<Loader bind:loading>
			{$_('End date for prediction')}
			<DateInput
				bind:value={newPredictionStatement.end_date}
				min={new Date()}
				max={maxDatePickerYear}
			/>
			<span>{$_('Select Proposals to predict on')}</span>
			<Question
				message={`Predict on what will happen if a proposal is implemented in reality. Predicting on multiple proposals ammounts to saying "if proposal x and proposal y is implemented in reality, this will be the outcome"`}
			/><br />
			<div class="grid grid-cols-1">
				{#each proposals as proposal}
					{#key resetsOfValues}
						<Select
							label={proposal.title}
							Class="mt-2"
							onInput={(e) => {
								//@ts-ignore
								if (e.target.value === 'Neutral')
									newPredictionStatement.segments?.filter(
										(segment) => segment.proposal_id === proposal.id
									);
								else if (
									newPredictionStatement.segments.find(
										(segment) => segment.proposal_id === proposal.id
									)
								)
									newPredictionStatement.segments.map((segment) => {
										if (segment.proposal_id === proposal.id)
											//@ts-ignore
											segment.is_true = e.target.value === 'Implemented' ? true : false;
									});
								else
									newPredictionStatement.segments.push({
										proposal_id: proposal.id,
										//@ts-ignore
										is_true: e.target.value === 'Implemented' ? true : false
									});
							}}
							labels={['Neutral', 'Implemented', 'Not implemented']}
							values={[null, 'Implemented', 'Not implemented']}
							value={null}
						/>
					{/key}
				{/each}
			</div>
			<br />
			<TextArea required label="Description" bind:value={newPredictionStatement.description} />
			<!-- <StatusMessage bind:status={statusMessage} /> -->
			<Button type="submit">{$_('Submit')}</Button>
			<Button action={getAIpredictionStatement}>{$_('Let AI help')}</Button>
			<Button buttonStyle="warning">{$_('Cancel')}</Button>
		</Loader>
	</form>
</Modal>

<SuccessPoppup bind:message bind:show />

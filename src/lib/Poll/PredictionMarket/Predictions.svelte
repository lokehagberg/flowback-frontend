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
	import type { PredictionBet, PredictionStatement } from './interfaces';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import { createPrediction as createPredictionBlockchain } from '$lib/Blockchain/javascript/predictionsBlockchain';
	import { getGroupInfo } from '../functions';

	export let proposals: proposal[], phase: Phase;

	let loading = false,
		predictions: PredictionStatement[] = [],
		addingPrediction = false,
		newPredictionStatement: {
			description?: string;
			end_date?: Date;
			blockchain_id?: number;
			segments: {
				proposal_id: number;
				is_true: boolean;
			}[];
		} = { segments: [] },
		// statusMessage: StatusMessageInfo,
		bets: PredictionBet[] = [],
		resetsOfValues = 0,
		poppup: poppup,
		pushToBlockchain = true;

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
		let prediction_blockchain_id;

		if (import.meta.env.VITE_BLOCKCHAIN_INTEGRATION === 'TRUE' && pushToBlockchain)
			for (let i = 0; i < newPredictionStatement.segments.length; i++) {
				try {
					const proposal = proposals.find(
						(proposal) => newPredictionStatement.segments[i].proposal_id === proposal.id
					);
					const { json, res } = await getGroupInfo($page.params.groupId);
					if (proposal?.blockchain_id) {
						prediction_blockchain_id = await createPredictionBlockchain(
							json[0].blockchain_id,
							proposal.blockchain_id
						);
					}
					newPredictionStatement.blockchain_id = prediction_blockchain_id;
				} catch {
					poppup = { message: 'Could not push to Blockchain', success: false };
				}
			}

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/prediction/statement/create`,
			newPredictionStatement
		);
		loading = false;

		if (!res.ok) {
			poppup = { message: json.detail[0], success: false };
			return;
		}

		newPredictionStatement = { segments: [] };
		resetsOfValues++;
		addingPrediction = false;
		poppup = { message: 'Successfully created prediction statement', success: true };

		getPredictionStatements();
	};

	const deletePredictionStatement = async (id: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${id}/statement/delete`
		);
	};

	const getAIpredictionStatement = async () => {
		let proposalsString = '';
		proposals.forEach((proposal) => {
			proposalsString += `- ${proposal.title}\n`;
		});

		const { res, json } = await fetchRequest('POST', 'ai/prediction_statement', {
			prompt: proposalsString
		});
		newPredictionStatement.description = json.predictions;
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

	{#if phase === 'prediction_statement'}
		<Button action={() => (addingPrediction = true)}>{$_('New Prediction')}</Button>
	{/if}

	{#if predictions.length === 0}
		<div class="mt-5">{$_('There are currently no predictions')}</div>
	{/if}
</Loader>

<!-- Is displayed whenever a prediction statement is being added -->
<Modal bind:open={addingPrediction} onSubmit={createPredictionStatement}>
	<div slot="header">{$_('New Prediction')}</div>
	<div slot="body">
		<Loader bind:loading>
			{$_('Deadline for prediction')}
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
			<RadioButtons bind:Yes={pushToBlockchain} label="Push to Blockchain?" />
			<Button type="submit">{$_('Submit')}</Button>
			{#if import.meta.env.VITE_FLOWBACK_AI_MODULE}
				<Button action={getAIpredictionStatement}>{$_('Let AI help')}</Button>
			{/if}
			<Button buttonStyle="warning">{$_('Cancel')}</Button>
		</Loader>
	</div>
</Modal>

<Poppup bind:poppup />

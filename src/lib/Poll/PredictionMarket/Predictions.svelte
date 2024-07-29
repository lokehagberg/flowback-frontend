<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import Loader from '$lib/Generic/Loader.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import DateInput from 'date-picker-svelte/DateInput.svelte';
	import type { Phase, poll, proposal } from '../interface';
	import Question from '$lib/Generic/Question.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import { maxDatePickerYear } from '$lib/Generic/DateFormatter';
	import type { PredictionBet, PredictionStatement } from './interfaces';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import { createPrediction as createPredictionBlockchain } from '$lib/Blockchain/javascript/predictionsBlockchain';

	export let proposals: proposal[],
		phase: Phase,
		poll: poll,
		proposalsToPredictionMarket: proposal[] = [];

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
		pushingToBlockchain = true;

	const getPredictionStatements = async () => {
		loading = true;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/prediction/statement/list?poll_id=${$page.params.pollId}`
		);
		loading = false;
		console.log(json.results);
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

		if (import.meta.env.VITE_BLOCKCHAIN_INTEGRATION === 'TRUE' && pushingToBlockchain)
			await pushToBlockchain();

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
		return;

		getPredictionStatements();
	};

	const deletePredictionStatement = async (id: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${id}/statement/delete`
		);
	};

	//Go through every proposal that the prediction statement is predicting on.
	// If the proposal is pushed to blockchain, push the prediction on that proposal to blockchain
	const pushToBlockchain = async () => {
		let prediction_blockchain_id;

		for (let i = 0; i < newPredictionStatement.segments.length; i++) {
			try {
				const proposal = proposals.find(
					(proposal) => newPredictionStatement.segments[i].proposal_id === proposal.id
				);

				// if (proposal?.blockchain_id && group.blockchain_id) {
				if (proposal?.blockchain_id && poll.blockchain_id) {
					prediction_blockchain_id = await createPredictionBlockchain(
						poll.blockchain_id,
						proposal.blockchain_id,
						newPredictionStatement.description || ''
					);
				}
				newPredictionStatement.blockchain_id = Number(`${prediction_blockchain_id}`);
			} catch {
				poppup = { message: 'Could not push to Blockchain', success: false };
			}
		}
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

<div>{$_('New Prediction')}</div>
<div>
	{#if proposalsToPredictionMarket}
		{#each proposalsToPredictionMarket as proposal}
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
							newPredictionStatement.segments.find((segment) => segment.proposal_id === proposal.id)
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
					labels={['Implemented', 'Not implemented']}
					values={['Implemented', 'Not implemented']}
					value={'Implemented'}
				/>
			{/key}
		{/each}
	{/if}
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
		<div class="grid grid-cols-1" />
		<br />
		<TextArea required label="Description" bind:value={newPredictionStatement.description} />
		<RadioButtons bind:Yes={pushingToBlockchain} label="Push to Blockchain?" />
		<Button type="submit">{$_('Submit')}</Button>
		{#if import.meta.env.VITE_FLOWBACK_AI_MODULE}
			<Button action={getAIpredictionStatement}>{$_('Let AI help')}</Button>
		{/if}
		<Button buttonStyle="warning">{$_('Cancel')}</Button>
	</Loader>
</div>
<!-- </Modal> -->

<Poppup bind:poppup />

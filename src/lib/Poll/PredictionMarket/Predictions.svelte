<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import Loader from '$lib/Generic/Loader.svelte';
	import Prediction from './Prediction.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import DatePicker from 'date-picker-svelte/DatePicker.svelte';
	import DateInput from 'date-picker-svelte/DateInput.svelte';
	import type { proposal } from '../interface';
	import Question from '$lib/Generic/Question.svelte';

	let loading = false,
		predictions: any[] = [],
		addingPrediction = false,
		prediction_statement_id = 0,
		newPredictionStatement: {
			description?: string;
			end_date?: Date;
			segments?: {
				proposal_id: number;
				is_true: boolean;
			}[];
		} = {};

	export let proposals: proposal[];

	const getPredictions = async () => {
		// 	`group/${$page.params.groupId}/delegate/pools?id=${history}`
		loading = true;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/prediction/statement/list`
		);
		loading = false;
		console.log(json.results, 'JSON?!!!');
		predictions = json.results;
	};

	const createPredictionStatement = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/prediction/statement/create`,
			newPredictionStatement
		);
	};
	const deletePredictionStatement = async (id: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/prediction/${id}/statement/delete`
		);
	};
	const updatePredictionStatement = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/prediction/statement/update`,
			newPredictionStatement
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

	const test = async () => {
		// const { res, json } = await fetchRequest(
		// 	'GET',
		// 	`group/${$page.params.groupId}/poll/prediction/list`
		// );
		// const { res, json } = await fetchRequest(
		// 	'POST',
		// 	`group/poll/${1}/prediction/create`, {score:4}
		// 	)
		// const { res, json } = await fetchRequest(
		// 	'POST',
		// 	`group/poll/${1}/prediction/update`, {score:5}
		// 	)
		// const { res, json } = await fetchRequest(
		// 	'POST',
		// 	`group/poll/${1}/prediction/delete`
		// 	)
	};

	onMount(() => {
		getPredictions();
	});

	const handleProposalCheckboxChange = async () => {};
</script>

<Loader bind:loading>
	<h2>{$_('Prediction Market')}</h2>
	<ul>
		{#each predictions as prediction}
			<li><Prediction {prediction} /></li>
		{/each}
	</ul>

	<Button action={() => (addingPrediction = true)}>Add Prediction</Button>

	<Button action={test}>Test</Button>
</Loader>

<Modal bind:open={addingPrediction}>
	<div slot="header">Add Prediction</div>
	<form slot="body" on:submit={createPredictionStatement}>
		<TextArea label="Description" bind:value={newPredictionStatement.description} />
		End date for prediction<DateInput bind:value={newPredictionStatement.end_date} />
		<span>Select Proposals to predict on</span>
		<Question
			message={`Predict on what will happen if a proposal is implemented in reality. Predicting on multiple proposals ammounts to saying "if proposal x and proposal y is implemented in reality, this will be the outcome"`}
		/><br />
		{#each proposals as proposal}
			
			<input
				type="checkbox"
				value={proposal.id}
				name={proposal.title}
				on:input={(e) => {
					//@ts-ignore
					e.target.checked ? newPredictionStatement.segments.append({
						proposal_id:proposal.id,
						is_true:true
					}) : newPredictionStatement.segments?.filter(segment => segment.proposal_id === proposal.id);
				}}
			/> 
			<input
				type="checkbox"
				value={proposal.id}
				name={proposal.title}
				on:input={(e) => {
					//@ts-ignore
					e.target.checked ? newPredictionStatement.segments.append({
						proposal_id:proposal.id,
						is_true:true
					}) : newPredictionStatement.segments?.filter(segment => segment.proposal_id === proposal.id);
				}}
			/> <label for={proposal.id.toString()}>{proposal.title}</label> <br />
		{/each}
		<Button type="submit">Submit</Button>
		<Button buttonStyle="warning">Cancel</Button>
	</form>
</Modal>

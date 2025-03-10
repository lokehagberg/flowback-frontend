<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import Loader from '$lib/Generic/Loader.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import DateInput from 'date-picker-svelte/DateInput.svelte';
	import type { poll, proposal } from '../interface';
	import Question from '$lib/Generic/Question.svelte';
	import { maxDatePickerYear } from '$lib/Generic/DateFormatter';
	import type { PredictionBet, PredictionStatement } from './interfaces';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import { createPrediction as createPredictionBlockchain } from '$lib/Blockchain_v1_Ethereum/javascript/predictionsBlockchain';
	import Fa from 'svelte-fa';
	import { faX } from '@fortawesome/free-solid-svg-icons';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { env } from '$env/dynamic/public';

	export let proposals: proposal[],
		poll: poll,
		proposalsToPredictionMarket: proposal[] = [];

	let loading = false,
		newPredictionStatement: {
			title?: string;
			description?: string;
			end_date?: Date;
			blockchain_id?: number;
			segments: {
				proposal_id: number;
				is_true: boolean;
			}[];
		} = { segments: [] },
		bets: PredictionBet[] = [],
		poppup: poppup,
		pushingToBlockchain = true;

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
		if (newPredictionStatement.description === '') newPredictionStatement.description = undefined;

		if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE' && pushingToBlockchain)
			await pushToBlockchain();

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/prediction/statement/create`,
			newPredictionStatement
		);
		loading = false;

		if (!res.ok) {
			poppup = { message: 'Could not create prediction statement', success: false };
			return;
		}

		newPredictionStatement = {
			segments: newPredictionStatement.segments,
			description: '',
			end_date: newPredictionStatement.end_date,
			blockchain_id: 0,
			title: ''
		};
		poppup = { message: 'Successfully created prediction statement', success: true };
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

	const handleImplementationStatusChange = (
		value: 'Neutral' | 'Implemented' | 'Not Implemented',
		proposal: proposal
	) => {
		//@ts-ignore
		if (value === 'Neutral')
			newPredictionStatement.segments?.filter((segment) => segment.proposal_id === proposal.id);
		else if (newPredictionStatement.segments.find((segment) => segment.proposal_id === proposal.id))
			newPredictionStatement.segments.map((segment) => {
				if (segment.proposal_id === proposal.id)
					//@ts-ignore
					segment.is_true = value === 'Implemented' ? true : false;
			});
		else
			newPredictionStatement.segments.push({
				proposal_id: proposal.id,
				//@ts-ignore
				is_true: value === 'Implemented' ? true : false
			});
	};

	const handleChangeProposalSelection = () => {
		newPredictionStatement.segments = [];
		proposalsToPredictionMarket.forEach((proposal) => {
			handleImplementationStatusChange('Implemented', proposal);
		});
	};

	const removeProposal = (proposal: proposal) => {
		const i = proposalsToPredictionMarket.findIndex((_proposal) => {
			_proposal === proposal;
		});
		proposalsToPredictionMarket.splice(i, 1);
		proposalsToPredictionMarket = proposalsToPredictionMarket;
	};

	onMount(() => {
		getPredictionBets();
	});

	$: if (proposalsToPredictionMarket) handleChangeProposalSelection();
</script>

<div class="flex flex-row mb-4">
	<span class="flex-1 font-semibold text-primary dark:text-secondary">{$_('New Prediction')}</span>
	<div class="flex-1">
		<Question
			message={`Predict on what will happen if a proposal is implemented in reality. Predicting on multiple proposals ammounts to saying "if proposal x and proposal y is implemented in reality, this will be the outcome"`}
		/><br />
	</div>
</div>

{#key proposalsToPredictionMarket}
	{#if proposalsToPredictionMarket}
		<div class="flex flex-col gap-2">
			<span>{$_('If implemented')}</span>
			{#each proposalsToPredictionMarket as proposal, i}
				{#if i !== 0} {$_('OR')} {/if}
				<div class="flex justify-between">
					<span class="p-0.5 border border-gray-300 rounded w-full">{proposal.title}</span>
					<button class="p-2" type="button" on:click={() => removeProposal(proposal)}>
						<Fa icon={faX} color="red" />
					</button>
				</div>
			{/each}
		</div>
	{/if}
{/key}

<Loader bind:loading Class="!static h-full pt-3">
	<form on:submit|preventDefault={createPredictionStatement} class="h-full">
		<TextInput required label="Title" bind:value={newPredictionStatement.title} />
		<div class="mt-3">
			<TextArea label="Description" bind:value={newPredictionStatement.description} />
		</div>
		{#if env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE'}
			<RadioButtons Class="mt-3" bind:Yes={pushingToBlockchain} label="Push to Blockchain" />
		{/if}
		<div class="mt-2">
			{$_('Deadline for prediction')}
			<DateInput
				bind:value={newPredictionStatement.end_date}
				min={new Date()}
				max={maxDatePickerYear}
			/>
		</div>

		<div class="flex gap-2 absolute bottom-0 w-full">
			<Button type="submit" buttonStyle="primary-light" Class="w-full mt-5">{$_('Submit')}</Button>
			<Button type="submit" buttonStyle="warning-light" Class="w-full mt-5">{$_('Cancel')}</Button>
			{#if env.PUBLIC_FLOWBACK_AI_MODULE === 'TRUE'}
				<Button Class="w-full mt-5" onClick={getAIpredictionStatement}>{$_('Let AI help')}</Button>
			{/if}
		</div>
	</form>
</Loader>

<Poppup bind:poppup />

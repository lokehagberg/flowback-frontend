<!-- The new Proposal file, <Proposal/> is depricated. TODO: Remove Proposal, renmae ProposalNew to Proposal -->
<script lang="ts">
	import type { Comment, Phase, proposal } from './interface';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';
	import { checkForLinks } from '$lib/Generic/GenericFunctions';
	import {
		faChevronRight,
		faSquareCheck,
		faMagnifyingGlassChart
	} from '@fortawesome/free-solid-svg-icons';
	import { faSquare } from '@fortawesome/free-regular-svg-icons';
	import Fa from 'svelte-fa';
	import commentSymbol from '$lib/assets/iconComment.svg';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';

	export let proposal: proposal,
		Class = '',
		onChange = (e: Event) => {},
		isVoting = true,
		voting: { score: number; proposal: number }[] = [],
		selectedProposal: proposal | null = null,
		proposalsToPredictionMarket: proposal[] = [],
		phase: Phase,
		comments: Comment[] = [],
		allComments: Comment[] = [],
		predictionCount = 0,
		commentFilterProposalId: number | null = null,
		selectedForCommentFiltering = false;

	export const id: number = 0;

	const filterComments = () => {
		if (commentFilterProposalId === proposal.id) {
			comments = allComments;
			commentFilterProposalId = null;
		} else {
			comments = allComments;
			comments = comments.filter(
				//@ts-ignore
				(comment) => comment.message.includes(`#${proposal.title.replaceAll(' ', '-')}`)
			);

			commentFilterProposalId = proposal.id;
		}
	};

	const getPredictionCount = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/prediction/statement/list?poll_id=${$page.params.pollId}&proposals=${proposal.id}`
		);
		predictionCount = json.results.length;
	};

	onMount(() => {
		checkForLinks(proposal.description, `proposal-${proposal.id}-description`);
		getPredictionCount();
		allComments = comments;
	});
</script>

<button
	class={`dark:bg-darkobject bg-white w-full py-3 px-3 transition-all
	 dark:border-gray-500 ${Class}`}
	class:!bg-blue-100={selectedProposal === proposal}
	class:border-l-2={selectedProposal === proposal}
	class:border-primary={selectedProposal === proposal}
>
	<div class="flex gap-2 items-center">
		{#if phase === 'prediction_statement'}
			{@const proposalInList = proposalsToPredictionMarket.findIndex(
				(prop) => prop.id === proposal.id
			)}
			{#if proposalInList !== -1}
				<button
					on:click={() => {
						proposalsToPredictionMarket.splice(proposalInList, 1);
						proposalsToPredictionMarket = proposalsToPredictionMarket;
					}}
				>
					<Fa icon={faSquareCheck} class="text-primary cursor-pointer" />
				</button>
			{:else}
				<button
					on:click={() => {
						proposalsToPredictionMarket.push(proposal);
						proposalsToPredictionMarket = proposalsToPredictionMarket;
					}}
				>
					<Fa icon={faSquare} class="text-primary cursor-pointer" />
				</button>
			{/if}
		{/if}
		<!-- Proposal Title -->
		<span
			class="text-md text-primary dark:text-secondary font-semibold align-text-top text-left break-words"
			>{proposal.title}</span
		>
	</div>

	<!-- Proposal Description -->
	<p
		class="elipsis text-sm text-left my-1 break-words whitespace-pre-wrap"
		id={`proposal-${proposal.id}-description`}
	>
		{proposal.description}
	</p>

	<slot />

	<div class="flex justify-between w-full items-center">
		<div class="flex justify-between gap-10">
			<button class="flex" on:click={filterComments}>
				<img
					src={commentSymbol}
					alt="Comment"
					class="w-6 h-6 mr-2"
					class:saturate-0={commentFilterProposalId !== proposal.id &&
						commentFilterProposalId !== null}
				/>
				{allComments.filter((comment) => comment?.message?.includes(proposal.title)).length}
			</button>

			{#if phase !== 'proposal'}
				<button
					class="flex items-center"
					on:click={() => {
						console.log(proposal, "PROPOSAL1");
						
						selectedProposal = proposal;
					}}
				>
				<Fa icon={faMagnifyingGlassChart} class="mr-4 text-primary" size="md" />
				{predictionCount}
			</button>
			{/if}
		</div>
		
		<button
		on:click={() => {
				console.log(proposal, "PROPOSAL1");
				selectedProposal = proposal;
			}}
			class="hover:underline cursor-pointer flex gap-2 items-baseline text-sm text-gray-700"
		>
			{$_('See More')}
			<Fa icon={faChevronRight} size="xs" />
		</button>
	</div>
</button>

{#if isVoting}
	<input
		value={voting.find((vote) => vote.proposal === proposal.id)?.score}
		id="amount"
		class="dark:bg-darkobject dark:border-gray-600 dark:hover:brightness-110 border-b-2"
		type="number"
		on:change={(e) => onChange(e)}
		min={0}
		max={100}
	/>
{:else}
	<!-- Ensures flex design stays intact -->
	<div />
{/if}

<style>
	.elipsis {
		text-overflow: ellipsis;
		overflow: hidden;
		/* // Addition lines for 2 line or multiline ellipsis */
		display: -webkit-box !important;
		-webkit-line-clamp: 2;
		line-clamp: 2;
		-webkit-box-orient: vertical;
		white-space: normal;
	}

	.proposal {
		transition: box-shadow 0.15s ease-in;
	}
</style>

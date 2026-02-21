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
	import { commentsStore, filterByTags } from '$lib/Comments/commentStore';
	import { darkModeStore } from '$lib/Generic/DarkMode';
	import { predictionStatementsStore } from './PredictionMarket/interfaces';
	import { idfy } from '$lib/Generic/GenericFunctions2';
	import { page } from '$app/stores';
	import { env } from '$env/dynamic/public';

	export let proposal: proposal,
		Class = '',
		selectedProposal: proposal | null = null,
		proposalsToPredictionMarket: proposal[] = [],
		proposals: proposal[] = [],
		phase: Phase,
		filteredComments: Comment[] = [],
		allComments: Comment[] = [],
		commentFilterProposalId: number | null = null;

	export const id: number = 0;

	const handleClickedCommentSymbol = () => {
		if (commentFilterProposalId === proposal.id) {
			commentsStore.update((store) => ({
				allComments: store.allComments,
				filterByProposal: null,
				filteredComments: store.allComments
			}));
			commentFilterProposalId = null;
			return;
		}

		filterByTags(proposals, [proposal.id], $page.params.pollId ?? '');
		commentFilterProposalId = proposal.id;
		// Scroll to the comments section
		const comments = document.getElementById('comments');

		scrollTo({
			top: comments?.offsetTop,
			behavior: 'smooth'
		});
	};

	onMount(() => {
		checkForLinks(proposal.description, `proposal-${proposal.id}-description`);
		allComments = filteredComments;
	});
</script>

<div
	class={`dark:bg-darkobject bg-white w-full py-3 px-4 transition-all rounded-lg
	 border border-gray-200 dark:border-gray-700 ${Class}`}
	class:!bg-blue-100={selectedProposal === proposal && !$darkModeStore}
	class:!bg-blue-950={selectedProposal === proposal && $darkModeStore}
	class:border-l-4={selectedProposal === proposal}
	class:border-primary={selectedProposal === proposal}
	id={`${idfy(proposal.title)}`}
>
	<div class="flex gap-2 items-center">
		{#if phase === 'prediction_statement'}
			{@const proposalInList = proposalsToPredictionMarket.findIndex(
				(prop) => prop.id === proposal.id
			)}
			<!-- Javascript returns -1 if index not found -->
			{#if proposalInList !== -1}
				<button
					id={`${idfy(proposal.title)}-selected`}
					on:click={() => {
						proposalsToPredictionMarket.splice(proposalInList, 1);
						proposalsToPredictionMarket = proposalsToPredictionMarket;
					}}
				>
					<Fa icon={faSquareCheck} class="text-primary cursor-pointer" />
				</button>
			{:else}
				<button
					id={`${idfy(proposal.title)}-selection`}
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
			class="text-md max-w-[300px] elipsis text-primary dark:text-secondary font-semibold align-text-top text-left break-words"
			>{proposal.title}</span
		>
	</div>
	<!-- Proposal Description -->
	<p
		class="elipsis max-w-[300px] text-sm text-left my-1 break-words whitespace-pre-wrap"
		id={`proposal-${proposal.id}-description`}
	>
		{proposal.description}
	</p>

	<div class="mt-2 mb-1">
		<slot />
	</div>

	<div class="flex justify-between w-full items-center">
		<div class="flex justify-between gap-10">
			<button class="flex" on:click={handleClickedCommentSymbol}>
				<img
					src={commentSymbol}
					alt="Comment"
					class="w-6 h-6 mr-2"
					class:saturate-0={commentFilterProposalId !== proposal.id}
				/>

				{$commentsStore.allComments.filter((comment) =>
					comment?.message?.includes(`#${proposal.title.replaceAll(' ', '-')}`)
				).length}
			</button>

			{#if phase !== 'proposal' && env.PUBLIC_POLL_VERSION === '1'}
				<button
					class="flex items-center"
					on:click={() => {
						selectedProposal = proposal;
					}}
				>
					<Fa
						icon={faMagnifyingGlassChart}
						class="mr-4 text-primary"
						size="md"
					/>
					{$predictionStatementsStore.filter((statement) =>
						statement.segments.find(
							(segment) => segment.proposal_id === proposal.id
						)
					).length}
				</button>
			{/if}
		</div>

		<button
			on:click={() => {
				selectedProposal = proposal;
			}}
			class="hover:underline cursor-pointer flex gap-2 items-baseline text-sm text-gray-700 dark:text-darkmodeText"
		>
			{$_('See more')}
			<Fa icon={faChevronRight} size="xs" />
		</button>
	</div>
</div>

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

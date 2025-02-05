<!-- The new Proposal file, <Proposal/> is depricated. TODO: Remove Proposal, renmae ProposalNew to Proposal -->
<script lang="ts">
	import type { Comment, Phase, proposal } from './interface';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';
	import { checkForLinks } from '$lib/Generic/GenericFunctions';
	import { faComment, faSquareCheck } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import Button from '$lib/Generic/Button.svelte';

	export let proposal: proposal,
		Class = '',
		onChange = (e: Event) => {},
		isVoting = true,
		voting: { score: number; proposal: number }[] = [],
		selectedProposal: proposal | null = null,
		proposalsToPredictionMarket: proposal[] = [],
		phase: Phase,
		comments: Comment[] = [];

	export const id: number = 0;

	const filterComments = () => {
		//@ts-ignore
		comments = comments.filter((comment) => !comment.message.includes(`#${proposal.title.replaceAll(" ", "-")}`));
	};

	onMount(() => {
		checkForLinks(proposal.description, `proposal-${proposal.id}-description`);
	});
</script>

<button
	class={`dark:bg-darkobject bg-white w-full py-1 px-2 transition-all
	 dark:border-gray-500 ${Class}`}
	class:!bg-blue-100={selectedProposal === proposal}
	class:border-l-2={selectedProposal === proposal}
	class:border-primary={selectedProposal === proposal}
>
	<div class="flex gap-2 items-baseline">
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
					<Fa icon={faSquareCheck} color={'black'} class="cursor-pointer" />
				</button>
			{:else}
				<button
					on:click={() => {
						proposalsToPredictionMarket.push(proposal);
						proposalsToPredictionMarket = proposalsToPredictionMarket;
					}}
				>
					<Fa icon={faSquareCheck} color={'white'} class="border border-black cursor-pointer" />
				</button>
			{/if}
		{/if}
		<!-- Proposal Title -->
		<span class="text-md text-primary dark:text-secondary font-semibold align-text-top text-left break-all"
			>{proposal.title}</span
		>
	</div>
	<!-- Proposal Description -->
	<p class="elipsis text-sm text-left my-1 break-all" id={`proposal-${proposal.id}-description`}>
		{proposal.description}
	</p>

	<slot />

	<div class="flex justify-between w-full">
		<Button action={filterComments} Class="my-auto">
			<Fa icon={faComment} />
		</Button>
		<button
			on:click={() => {
				selectedProposal = proposal;
			}}
			class="hover:underline cursor-pointer"
		>
			{$_('See More')}
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

<!-- The new Proposal file, <Proposal/> is depricated. TODO: Remove Proposal, renmae ProposalNew to Proposal -->
<script lang="ts">
	//@ts-ignore
	import type { Phase, proposal } from './interface';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import { checkForLinks } from '$lib/Generic/GenericFunctions';
	import { faComment, faSquareCheck } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import type { PredictionStatement } from './PredictionMarket/interfaces';

	export let proposal: proposal,
		Class = '',
		onChange = (e: Event) => {},
		isVoting = true,
		voting: { score: number; proposal: number }[] = [],
		selectedProposal: proposal | null = null,
		proposalsToPredictionMarket: proposal[] = [],
		phase: Phase;

	export const id: number = 0;

	let isHoveredOver = false,
		show = false;

	onMount(() => {
		checkForLinks(proposal.description, `proposal-${proposal.id}-description`);
	});
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	class={`dark:bg-darkobject bg-white
	 dark:border-gray-500 ${Class}`}
	on:dragenter|preventDefault={() => (isHoveredOver = true)}
	on:dragleave|preventDefault={() => (isHoveredOver = false)}
	class:hidden={isHoveredOver}
>
	<div class="flex gap-2 items-center">
		{#if phase === 'prediction_statement'}
			{@const proposalInList = proposalsToPredictionMarket.findIndex(
				(prop) => prop.id === proposal.id
			)}
			{#if proposalInList !== -1}
				<!-- svelte-ignore a11y-click-events-have-key-events -->
				<div
					on:click={() => {
						proposalsToPredictionMarket.splice(proposalInList, 1);
						proposalsToPredictionMarket = proposalsToPredictionMarket;
					}}
				>
					<Fa icon={faSquareCheck} color={'black'} class="cursor-pointer" />
				</div>
			{:else}
				<!-- svelte-ignore a11y-click-events-have-key-events -->
				<div
					on:click={() => {
						proposalsToPredictionMarket.push(proposal);
						proposalsToPredictionMarket = proposalsToPredictionMarket;
					}}
				>
					<Fa icon={faSquareCheck} color={'white'} class="border border-black cursor-pointer" />
				</div>
			{/if}
		{/if}
		<span class="text-lg align-text-top">{proposal.title}</span>
	</div>
	<p class="elipsis text-sm mt-2" id={`proposal-${proposal.id}-description`}>
		{proposal.description}
	</p>

	<slot />

	<div class="flex justify-between w-full">
		<div>
			<Fa icon={faComment} />
		</div>
		<!-- svelte-ignore a11y-click-events-have-key-events -->
		<div
			on:click={() => {
				selectedProposal = proposal;
			}}
			class="hover:underline cursor-pointer"
		>
			See More
		</div>
	</div>
</div>
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
	<!-- Used to ensure flex design stays intact -->
	<div />
{/if}

<SuccessPoppup bind:show message="Successfully edited proposal" />

<style>
	.elipsis {
		text-overflow: ellipsis;
		overflow: hidden;
		/* // Addition lines for 2 line or multiline ellipsis */
		display: -webkit-box !important;
		-webkit-line-clamp: 2;
		-webkit-box-orient: vertical;
		white-space: normal;
	}

	.proposal {
		transition: box-shadow 0.15s ease-in;
	}
</style>

<!-- The new Proposal file, <Proposal/> is depricated. TODO: Remove Proposal, renmae ProposalNew to Proposal -->
<script lang="ts">
	//@ts-ignore
	import type { proposal } from './interface';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import { checkForLinks } from '$lib/Generic/GenericFunctions';

	export let proposal: proposal,
		Class = '',
		onChange = (e: Event) => {},
		isVoting = true,
		voting: { score: number; proposal: number }[];

	export const id: number = 0;

	let isHoveredOver = false,
		show = false;

	onMount(() => {
		checkForLinks(proposal.description, `proposal-${proposal.id}-description`);
	});
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	class={`select-none dark:bg-darkobject hover:shadow-2xl proposal flex 
	justify-between items-center bg-white gap-8 p-4 border border-gray-200
	 dark:border-gray-500 lg:h-36 xl:h-40 ${Class}`}
	on:dragenter|preventDefault={() => (isHoveredOver = true)}
	on:dragleave|preventDefault={() => (isHoveredOver = false)}
	class:hidden={isHoveredOver}
>
	<!-- <div><Fa icon={faBars} /></div> -->
	<div class="h-full w-2/3">
		<h1 class="text-lg text-left">{proposal.title}</h1>
		<p class="elipsis text-sm mt-2" id={`proposal-${proposal.id}-description`}>
			{proposal.description}
		</p>

		<div class="bottom-0">

			

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
	<slot />
</div>

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

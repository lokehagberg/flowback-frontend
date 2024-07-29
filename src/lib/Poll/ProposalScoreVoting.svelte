<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { Phase, proposal } from '$lib/Poll/interface';
	import Proposal from './Proposal.svelte';
	import { proposals as proposalsLimit } from '../Generic/APILimits.json';
	import { onMount } from 'svelte';
	import type { groupUser } from '$lib/Group/interface';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import { poll } from 'ethers/lib/utils';

	export let proposals: proposal[] = [],
		isVoting: boolean = false,
		selectedProposal: proposal | null = null,
		phase:Phase,
		proposalsToPredictionMarket:proposal[] = [];

	let voting: { score: number; proposal: number }[] = [],
		needsReload = 0,
		poppup: poppup;

	onMount(async () => {
		await getProposals();

		voting = proposals.map((proposal) => ({
			score: 0,
			proposal: proposal.id
		}));

		await getVotes();
		needsReload++;
	});

	const getProposals = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposals?limit=${proposalsLimit}`
		);

		proposals = json.results;
	};

	const getVotes = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposal/votes?limit=${proposalsLimit}`
		);

		if (!json.results || json.results.length === 0) return;

		voting = voting.map((vote) => ({
			score: (vote.score = json.results.find(
				(score: { score: number; proposal: number }) => score.proposal === vote.proposal
			).raw_score),
			proposal: vote.proposal
		}));
		voting = voting;
	};

	const delegateVote = async () => {
		const { json, res } = await fetchRequest(
			`POST`,
			`group/poll/${$page.params.pollId}/proposal/vote/delegate/update`,
			{
				proposals: voting.map((vote) => vote.proposal),
				scores: voting.map((vote) => vote.score)
			}
		);

		if (!res.ok) {
			poppup = {
				message: json.message,
				success: false
			};
			return;
		}
		poppup = {
			message: 'Successfully voted',
			success: true
		};
	};

	const vote = async () => {
		const { res, json } = await fetchRequest(
			`POST`,
			`group/poll/${$page.params.pollId}/proposal/vote/update`,
			{
				proposals: voting.map((vote) => vote.proposal),
				scores: voting.map((vote) => vote.score)
			}
		);

		if (!res.ok) {
			poppup = {
				message: json.message,
				success: false
			};
			return;
		}
		poppup = {
			message: 'Successfully voted',
			success: true
		};
	};

	const changingVote = (e: Event, proposalId: number) => {
		//@ts-ignore
		let newScore = e?.target?.value;
		const i = voting.findIndex((vote) => vote.proposal === proposalId);
		voting[i].score = Number(newScore);
		voting = voting;
	};
</script>

<div class="overflow-y-scroll box-border">
	<span class="text-center text-blue-500 text-2xl">All proposals ({proposals.length})</span>
	<div class="mt-4 overflow-y-scroll h-[100%]">
		{#if proposals}
			{#key needsReload}
				{#each proposals as proposal}
					<Proposal
						{proposal}
						{isVoting}
						{voting}
						onChange={(e) => changingVote(e, proposal.id)}
						bind:proposalsToPredictionMarket
						bind:selectedProposal
						bind:phase
					/>
				{/each}
			{/key}
		{/if}
	</div>
</div>

{#if isVoting}
	<Button action={() => (false ? delegateVote() : vote())} Class="w-[30%]">Save Votings</Button>
	<!-- <Button action={() => (groupUser.is_delegate ? delegateVote() : vote())} Class="w-[30%]" -->
{/if}

<Poppup bind:poppup />

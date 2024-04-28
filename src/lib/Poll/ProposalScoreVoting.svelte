<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { proposal } from '$lib/Poll/interface';
	import ProposalNew from './ProposalNew.svelte';
	import { proposals as proposalsLimit } from '../Generic/APILimits.json';
	import { onMount } from 'svelte';
	import type { groupUser } from '$lib/Group/interface';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';

	export let proposals: proposal[] = [],
		groupUser: groupUser,
		isVoting: boolean = false;

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

		voting = voting.map((vote) => ({
			score: (vote.score = json.results.find(
				(score: { score: number; proposal: number }) => score.proposal === vote.proposal
			).raw_score),
			proposal: vote.proposal
		}));
		voting = voting;
	};

	const delegateVote = async () => {
		const {json, res} = await fetchRequest(`POST`, `group/poll/${$page.params.pollId}/proposal/vote/delegate/update`, {
			proposals: voting.map((vote) => vote.proposal),
			scores: voting.map((vote) => vote.score)
		});

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

<div class="">
	{#key needsReload}
		{#each proposals as proposal}
			<ProposalNew {proposal} onChange={(e) => changingVote(e, proposal.id)} {isVoting} {voting} />
		{/each}
	{/key}
</div>

{#if isVoting}
	<Button action={() => (groupUser.is_delegate ? delegateVote() : vote())} Class="w-[30%]"
		>Save Votings</Button
	>
{/if}

<Poppup bind:poppup />

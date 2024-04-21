<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { proposal } from '$lib/Poll/interface';
	import ProposalNew from './ProposalNew.svelte';
	import { proposals as proposalsLimit } from '../Generic/APILimits.json';
	import { onMount } from 'svelte';
	import type { groupUser } from '$lib/Group/interface';

	export let proposals: proposal[] = [],
		groupUser: groupUser,
		isVoting: boolean = false;

	let voting: { score: number; proposal: number }[] = [],
		needsReload = 0;

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

		console.log(voting);
		voting = voting.map((vote) => ({
			score: (vote.score = json.results.find(
				(score: { score: number; proposal: number }) => score.proposal === vote.proposal
			).raw_score),
			proposal: vote.proposal
		}));
		console.log(voting, 'VOTING DONE');
		voting = voting;
	};

	const delegateVote = () => {
		fetchRequest(`POST`, `group/poll/${$page.params.pollId}/proposal/vote/delegate/update`, {
			proposals: voting.map((vote) => vote.proposal),
			scores: voting.map((vote) => vote.score)
		});
	};

	const vote = () => {
		fetchRequest(`POST`, `group/poll/${$page.params.pollId}/proposal/vote/update`, {
			proposals: voting.map((vote) => vote.proposal),
			scores: voting.map((vote) => vote.score)
		});
	};

	const changingVote = (e: Event, proposalId: number) => {
		//@ts-ignore
		let newScore = e?.target?.value;
		const i = voting.findIndex((vote) => vote.proposal === proposalId);
		voting[i].score = Number(newScore);
		voting = voting;
	};
</script>

<div>
	{#key needsReload}
		{#each proposals as proposal}
			<ProposalNew {proposal} onChange={(e) => changingVote(e, proposal.id)} {isVoting} {voting} />
		{/each}
	{/key}

	{#if isVoting}
		<Button action={() => (groupUser.is_delegate ? delegateVote() : vote())} Class="mt-4">Save Votings</Button>
	{/if}
</div>

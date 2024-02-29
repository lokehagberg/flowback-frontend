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
		isVoting: boolean;

	let voting: { score: number; proposal: number }[] = [];

	onMount(() => {
		let interval = setInterval(() => {
			voting = proposals.map((proposal) => ({
				score: 0,
				proposal: proposal.id
			}));
			if (voting.length > 0) clearInterval(interval);
		}, 300);
	});

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

	const getProposals = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposals?limit=${proposalsLimit}`
		);

		proposals = json.results;
	};

	const changingVote = (e: Event, proposalId: number) => {
		console.log(voting, proposals);
		//@ts-ignore
		let newScore = e?.target?.value;
		const i = voting.findIndex((vote) => vote.proposal === proposalId);
		voting[i].score = Number(newScore);
		voting = voting;
	};

	onMount(() => {
		getProposals();
	});
</script>

<div>
	{#each proposals as proposal}
		<ProposalNew {proposal} onChange={(e) => changingVote(e, proposal.id)} {isVoting} />
	{/each}

	{#if isVoting}
		<Button action={() => (groupUser.is_delegate ? delegateVote() : vote())}>Save Votings</Button>
	{/if}
</div>

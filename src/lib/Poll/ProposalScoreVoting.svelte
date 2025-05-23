<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { Comment, Phase, poll, proposal } from '$lib/Poll/interface';
	import Proposal from './Proposal.svelte';
	import { proposals as proposalsLimit } from '../Generic/APILimits.json';
	import { onMount } from 'svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import VotingSlider from './VotingSlider.svelte';
	import { getGroupUserInfo } from '$lib/Generic/GenericFunctions';

	import { userGroupInfo, type groupUser } from '$lib/Group/interface';

	export let proposals: proposal[],
		isVoting: boolean = false,
		selectedProposal: proposal | null = null,
		phase: Phase,
		proposalsToPredictionMarket: proposal[] = [],
		Class = '',
		comments: Comment[],
		allComments: Comment[] = [],
		poll: poll;

	let voting: { score: number; proposal: number }[] = [],
		needsReload = 0,
		poppup: poppup,
		commentFilterProposalId: number | null = null,
		delegateRelations: any[] = [],
		delegates: any[] = [],
		delegateVoting: { score: number; proposal: number }[] = [];

	onMount(async () => {
		await getProposals();

		voting = proposals.map((proposal) => ({
			score: 0,
			proposal: proposal.id
		}));

		await getDelegateVotes();
		await getVotes();
		needsReload++;
	});

	const getProposals = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposals?limit=${proposalsLimit}`
		);

		if (!res.ok) return;

		proposals = json.results;
	};

	const getVotes = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposal/votes?limit=${proposalsLimit}`
		);

		if (!json?.results || json?.results?.length === 0) return;

		voting = voting.map((vote) => ({
			score: (vote.score = json.results.find(
				(score: { score: number; proposal: number }) => score.proposal === vote.proposal
			).raw_score),
			proposal: vote.proposal
		}));
		voting = voting;


	};



	const getDelegatePools = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegate/pools?limit=1000`
		);

		if (!res.ok) return;

		delegates = json.results.map((delegatePool: any) => {
			return { ...delegatePool.delegates[0].group_user, pool_id: delegatePool.id };
		});
	};

	const getDelegateRelations = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegates?limit=1000`
		);

		//Determines whether to show the "remove as delegate" or "add as delegate" buttons, depening on if user already has delegated or not earlier.
		json.results.forEach((relation: any) => {
			delegates.map((delegate) => {
				if (delegate.pool_id === relation.delegate_pool_id) delegate.isInRelation = true;
				return delegate;
			});
		});
		// delegateRelations = json.results;
		delegateRelations = json.results;
	};

	const getDelegateVotes = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/pool/votes?group_id=${$page.params.groupId}&poll_id=${$page.params.pollId}`
		);

		if (!res.ok) {
			console.error('Error fetching votes:', json.detail);
			return;
		}

		delegateVoting = json.results[0].vote.map((vote: any) => ({
			score: vote.raw_score,
			proposal: vote.proposal_id
		}));

		voting = delegateVoting
		console.log($userGroupInfo, "STORE");
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
			if (json.detail[0] === 'groupuserdelegatepool does not exist')
				poppup = {
					message: 'You cannot vote on this poll since you are not a delegate',
					success: false
				};
			else
				poppup = {
					message: 'Vote Failed',
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
				message: 'Vote Failed',
				success: false
			};
			return;
		}

		poppup = {
			message: 'Successfully voted',
			success: true
		};
	};

	const changingVote = (score: number | string, proposalId: number) => {
		const i = voting.findIndex((vote) => vote.proposal === proposalId);
		voting[i].score = Number(score);
		voting = voting;
	};
</script>

<div class={`box-border ${Class}`}>
	<div class="mt-4 h-[100%]">
		{#if proposals}
			{#key needsReload}
				{#each proposals as proposal}
					<div class="border-b-2 border-gray-300 select-none">
						<Proposal
							bind:proposalsToPredictionMarket
							bind:commentFilterProposalId
							bind:selectedProposal
							bind:filteredComments={comments}
							bind:phase
							onChange={() => {}}
							{proposal}
							{isVoting}
							{voting}
						>
							{#if phase === 'delegate_vote' || phase === 'vote'}
								{@const score = voting.find((vote) => vote.proposal === proposal.id)?.score}

								<VotingSlider
									onSelection={(pos) => {
										//@ts-ignore
										changingVote(pos, proposal.id);
										if (phase === 'delegate_vote') delegateVote();
										else if (phase === 'vote') vote();
									}}
									{score}
									{isVoting}
									delegateScore={delegateVoting.find((vote) => vote.proposal === proposal.id)?.score}
								/>
							{/if}
						</Proposal>
					</div>
				{/each}
			{/key}
		{/if}
	</div>
</div>

<!-- {#if isVoting}
	<Button action={() => (false ? delegateVote() : vote())} Class="w-[30%]">Save Votings</Button> -->
<!-- <Button action={() => (groupUser.is_delegate ? delegateVote() : vote())} Class="w-[30%]" -->
<!-- {/if} -->

<Poppup bind:poppup />

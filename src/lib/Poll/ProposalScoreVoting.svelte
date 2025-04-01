<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { Comment, Phase, proposal } from '$lib/Poll/interface';
	import Proposal from './Proposal.svelte';
	import { proposals as proposalsLimit } from '../Generic/APILimits.json';
	import { onMount } from 'svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import VotingSlider from './VotingSlider.svelte';
	import { getGroupUserInfo } from '$lib/Generic/GenericFunctions';

	import type { groupUser } from '$lib/Group/interface';

	export let proposals: proposal[],
		isVoting: boolean = false,
		selectedProposal: proposal | null = null,
		phase: Phase,
		proposalsToPredictionMarket: proposal[] = [],
		Class = '',
		comments: Comment[];

	let voting: { score: number; proposal: number }[] = [],
		needsReload = 0,
		poppup: poppup,
		commentFilterProposalId: number | null = null;

	onMount(async () => {
		await getProposals();

		voting = proposals.map((proposal) => ({
			score: 0,
			proposal: proposal.id
		}));

		console.log(proposals, 'PROP');
		console.log('WHAT THA HELLL');

		await getDelegateVotes();
		await getVotes();
		needsReload++;
	});

	const getProposals = async () => {
		console.log('HERE PROPOSAL SCORE GET PROPOSALS LAUNCHED!!!!');
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposals?limit=${proposalsLimit}`
		);

		console.log(json, 'JSON');

		if (!res.ok) return;

		proposals = json.results;
	};

	const getVotes = async () => {
		console.log('WHAT THA HELLL');

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

	const getDelegateVotes = async () => {
		const a: groupUser = await getGroupUserInfo($page.params.groupId);

		const { json } = await fetchRequest(
			'GET',
			`group/poll/pool/${a.delegate_pool_id}/votes?limit=${proposalsLimit}&poll_id=${$page.params.pollId}`
		);

		if (!json.results || json.results.length === 0) return;

		console.log(voting, json.results[0].vote, 'VÖTE');

		const votes = json.results[0].vote;

		voting.forEach((proposal) => {
			votes.forEach((vote: any) => {
				if (proposal.proposal === vote.proposal_id) {
					proposal.score = vote.raw_score;
					console.log(proposal, vote, 'proposal.score = vote.raw_score');
				}
			});
		});

		voting = voting;

		console.log(voting, 'VOTING????');

		// voting = voting.map((vote) => ({
		// 	score: (vote.score = json.results.find((v:any) => {
		// 		console.log(vote, v, 'VOTINGÖÖ');
		// 		//@ts-ignore
		// 		(score: { score: number; proposal: number }) => score.proposal_id === vote.proposal_id;
		// 	})?.raw_score),
		// 	proposal: vote.proposal
		// }));

		// voting = voting;
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
		//@ts-ignore
		// let newScore = e?.target?.value;
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
							bind:comments
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
										changingVote(pos, proposal.id);
										if (phase === 'delegate_vote') delegateVote();
										else if (phase === 'vote') vote();
									}}
									lineWidth={score ? score * 20 : 0}
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

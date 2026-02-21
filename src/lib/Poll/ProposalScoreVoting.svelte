<script lang="ts">
	import { page } from '$app/state';
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Comment, Phase, proposal } from '$lib/Poll/interface';
	import Proposal from './Proposal.svelte';
	import { proposals as proposalsLimit } from '../Generic/APILimits.json';
	import { onMount } from 'svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import VotingSlider from './VotingSlider.svelte';
	import {
		groupUserStore,
		groupUserPermissionStore
	} from '$lib/Group/interface';
	import { idfy } from '$lib/Generic/GenericFunctions2';
	import Fa from 'svelte-fa';
	import { faRotateLeft, faXmark } from '@fortawesome/free-solid-svg-icons';

	export let proposals: proposal[],
		selectedProposal: proposal | null = null,
		phase: Phase,
		proposalsToPredictionMarket: proposal[] = [],
		Class = '',
		comments: Comment[];

	let voting: { score: number; proposal: number }[] = [],
		needsReload = 0,
		commentFilterProposalId: number | null = null,
		// What my delegate has voted on
		delegateVoting: { score: number; proposal: number }[] = [];

	onMount(async () => {
		await getProposals();

		voting = proposals.map((proposal) => ({
			score: 0,
			proposal: proposal.id
		}));

		delegateVoting = voting;

		if (phase === 'delegate_vote' || phase === 'vote' || phase === 'result') {
			await getDelegateVotes();
		}

		if (phase === 'vote' || phase === 'result') {
			await getVotes();
		}

		// TODO: Remove "needsReload" while making sure things reload properly
		needsReload++;
	});

	const getProposals = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/${page.params.pollId}/proposals?limit=${proposalsLimit}`
		);

		if (!res.ok) return;

		proposals = json?.results;
	};

	// Getting one's own votes
	const getVotes = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/poll/${page.params.pollId}/proposal/votes?limit=${proposalsLimit}`
		);

		if (!res.ok) return;

		if (json.results.length === 0) return;

		voting = voting.map((vote) => ({
			score: (vote.score = json?.results?.find(
				(score: { score: number; proposal: number }) =>
					score.proposal === vote.proposal
			).raw_score),
			proposal: vote.proposal
		}));

		voting = voting;
	};

	// Getting the vote from one's delegate
	const getDelegateVotes = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/pool/votes?group_id=${page.params.groupId}&poll_id=${page.params.pollId}`
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to get delegate votes',
				success: false
			});
			return;
		}

		if (json?.results[0]?.vote?.length > 0) {
			delegateVoting = json?.results[0]?.vote.map((vote: any) => ({
				score: vote.raw_score,
				proposal: vote.proposal_id
			}));

			// Makes it so users vote matches their delegates vote
			voting = json?.results[0]?.vote.map((vote: any) => ({
				score: vote.raw_score,
				proposal: vote.proposal_id
			}));
		}
		voting = voting;
		delegateVoting = delegateVoting;
	};

	const handleSliderClick = async (pos: any, proposal: proposal) => {
		changingVote(pos, proposal.id);
		if (phase === 'delegate_vote') delegateVote();
		else if (phase === 'vote') vote();
	};

	// Voting as a delegate
	const delegateVote = async () => {
		const { json, res } = await fetchRequest(
			`POST`,
			`group/poll/${page.params.pollId}/proposal/vote/delegate/update`,
			{
				proposals: delegateVoting?.map((vote) => vote.proposal),
				scores: delegateVoting?.map((vote) => vote.score)
			}
		);

		if (!res.ok) {
			if (json?.detail[0] === 'groupuserdelegatepool does not exist')
				ErrorHandlerStore.set({
					message: 'You cannot vote on this poll since you are not a delegate',
					success: false
				});
			else
				ErrorHandlerStore.set({
					message: 'Vote Failed',
					success: false
				});
			return;
		}
		ErrorHandlerStore.set({
			message: 'Successfully voted',
			success: true
		});
	};

	const vote = async () => {
		const { res, json } = await fetchRequest(
			`POST`,
			`group/poll/${page.params.pollId}/proposal/vote/update`,
			{
				proposals: voting?.map((vote) => vote.proposal),
				scores: voting?.map((vote) => vote.score)
			}
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Vote Failed',
				success: false
			});
			return;
		}

		ErrorHandlerStore.set({
			message: 'Successfully voted',
			success: true
		});
	};

	const changingVote = (score: number | string, proposalId: number) => {
		if (!voting) return;

		if (phase === 'delegate_vote') {
			const i = delegateVoting?.findIndex(
				(vote) => vote.proposal === proposalId
			);
			delegateVoting[i].score = Number(score);
			delegateVoting = delegateVoting;
		} else if (phase === 'vote') {
			const i = voting?.findIndex((vote) => vote.proposal === proposalId);
			voting[i].score = Number(score);
			voting = voting;
		}

		needsReload++;
	};

	const getScore = (proposal: proposal) => {
		if (phase === 'delegate_vote')
			return (
				delegateVoting?.find((vote) => vote.proposal === proposal.id)?.score ??
				0
			);
		else if (phase === 'vote')
			return voting?.find((vote) => vote.proposal === proposal.id)?.score ?? 0;
	};
</script>

<div class={`box-border ${Class}`}>
	<div class="mt-4 h-[100%]">
		{#if proposals}
			{#key needsReload}
				{#each proposals as proposal}
					<div class="select-none mb-3">
						<Proposal
							bind:proposalsToPredictionMarket
							bind:commentFilterProposalId
							bind:proposals
							bind:selectedProposal
							bind:phase
							bind:filteredComments={comments}
							{proposal}
						>
							{#if phase === 'delegate_vote' || phase === 'vote'}
								{@const score = getScore(proposal)}
								{@const disabled =
									(phase === 'delegate_vote' &&
										$groupUserStore?.delegate_pool_id === null) ||
									(phase === 'vote' && !$groupUserPermissionStore?.allow_vote)}

								{#key voting || delegateVoting}
									<VotingSlider
										bind:phase
										onSelection={(pos) => handleSliderClick(pos, proposal)}
										style={disabled ? 'gray' : 'purple'}
										id={`${idfy(proposal.title)}`}
										{score}
										{disabled}
										hideClearButton={phase === 'vote' &&
											$groupUserPermissionStore?.allow_vote}
									/>
								{/key}

								{#if phase === 'vote' && $groupUserPermissionStore?.allow_vote}
									<div class="flex items-center gap-4 mt-2">
										<button
											class="flex items-center gap-1.5 text-sm text-purple-600 hover:text-purple-800 dark:text-purple-400 dark:hover:text-purple-300 transition-colors cursor-pointer"
											on:click={() => {
												const dVote = delegateVoting.find(
													(vote) => vote.proposal === proposal.id
												);
												if (dVote) changingVote(dVote.score, dVote.proposal);
												vote();
											}}
										>
											<Fa icon={faRotateLeft} size="sm" />
											{$_(
												$groupUserStore?.delegate_pool_id
													? 'Reset to my delegate vote'
													: 'Reset to delegate vote'
											)}
										</button>
										<button
											class="flex items-center gap-1.5 text-sm text-red-600 hover:text-red-700 dark:text-red-400 dark:hover:text-red-300 transition-colors cursor-pointer"
											on:click={() => {
												handleSliderClick(null, proposal);
											}}
										>
											<Fa icon={faXmark} size="sm" />
											{$_('Clear vote')}
										</button>
									</div>
								{:else if phase === 'delegate_vote' && $groupUserStore?.delegate_pool_id !== null}
									<button
										class="mt-2 flex items-center gap-1.5 text-sm text-red-400 hover:text-red-600 dark:text-red-400 dark:hover:text-red-300 transition-colors cursor-pointer"
										on:click={() => {
											handleSliderClick(null, proposal);
										}}
									>
										<Fa icon={faXmark} size="sm" />
										{$_('Clear vote')}
									</button>
								{/if}
							{/if}
						</Proposal>
					</div>
				{/each}
			{/key}
		{/if}
	</div>
</div>

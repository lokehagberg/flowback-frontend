<script lang="ts">
	import Comments from '$lib/Comments/Comments.svelte';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { Phase, poll, proposal } from '$lib/Poll/interface';
	import Button from '$lib/Generic/Button.svelte';
	import { _ } from 'svelte-i18n';
	import Results from '$lib/Poll/Results.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import type { groupUser } from '$lib/Group/interface';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import { checkForLinks, type StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import ProposalSubmition from '$lib/Poll/ProposalSubmition.svelte';
	import Predictions from '$lib/Poll/PredictionMarket/Predictions.svelte';
	import PollHeader from '$lib/Poll/PollHeader.svelte';
	import { getPhase } from '$lib/Poll/functions';
	import AreaVote from '$lib/Poll/AreaVote.svelte';
	import ProposalScoreVoting from '$lib/Poll/ProposalScoreVoting.svelte';
	import { goto } from '$app/navigation';
	import DatePoll from '$lib/Poll/DatePoll.svelte';
	import Structure from '$lib/Poll/NewDesign/Structure.svelte';
	import Proposal from '$lib/Poll/Proposal.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import PredictionStatements from '$lib/Poll/PredictionStatements.svelte';
	import { env } from '$env/dynamic/public';

	// TODO: refactor the phase system so be very modular
	//{#if phase === "phase x}
	//	 <PhaseX />
	// ...

	let poll: poll,
		selectedPage: 'You' | 'Delegate' = 'You',
		DeletePollModalShow = false,
		pollType = 1,
		finished: boolean,
		groupUser: groupUser,
		deleteStatus: StatusMessageInfo,
		phase: Phase,
		proposals: proposal[],
		selectedProposal: proposal | null,
		proposalsToPredictionMarket: proposal[] = [];

	onMount(async () => {
		getGroupUser();
		await getPollData();
		phase = getPhase(poll);
		scrollToSection();
		checkForLinks(poll?.description, 'poll-description');
		document.title = poll.title;
	});

	const getPollData = async () => {
		if (!$page.params) return;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/list?id=${$page.params.pollId}`
		);

		if (!res.ok) return;

		statusMessageFormatter(res, json);
		poll = json.results[0];
		pollType = json.results[0].poll_type;
		finished = new Date(json.results[0].end_date) < new Date();
	};

	const deletePoll = async () => {
		const { res, json } = await fetchRequest('POST', `group/poll/${$page.params.pollId}/delete`);
		if (res.ok) goto(`/groups/${$page.params.groupId}`);
		else deleteStatus = statusMessageFormatter(res, json, '');
	};

	//TODO: Replace this later with some kind of svelte stores or local storage data
	const getGroupUser = async () => {
		if (!$page.params) return;

		const { res, json } = await fetchRequest('GET', `user`);
		if (res.ok) {
			const userId = json.id;
			{
				const { res, json } = await fetchRequest(
					'GET',
					`group/${$page.params.groupId}/users?user_id=${userId}`
				);
				if (res.ok) groupUser = json.results[0];
			}
		}
	};

	const scrollToSection = () => {
		const section = $page.url.searchParams.get('section');
		if (!section) return;
		setTimeout(() => {
			const scrollTo = document.getElementById(section);
			scrollTo?.scrollIntoView({ behavior: 'instant', block: 'start', inline: 'nearest' });
		}, 200);
	};

	const nextPhase = async () => {
		let _phase: Phase = 'pre_start';

		if (pollType === 4) {
			if (phase === 'area_vote') _phase = 'proposal';
			else if (phase === 'proposal') _phase = 'prediction_statement';
			else if (phase === 'prediction_statement') _phase = 'prediction_bet';
			else if (phase === 'prediction_bet') _phase = 'delegate_vote';
			else if (phase === 'delegate_vote') _phase = 'vote';
			else if (phase === 'vote') _phase = 'prediction_vote';
		} else if (pollType === 3) _phase = 'result';

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/fast_forward`,
			{
				phase: _phase
			}
		);

		if (res.ok) phase = _phase;
	};
</script>

<Layout centered>
	{#if poll}
		<PollHeader {poll} {phase} displayTag={phase !== 'area_vote'} />

		{#if pollType === 4}
			{#if phase === 'pre_start'}
				<div />
				<!-- PHASE 1: AREA VOTE -->
			{:else if phase === 'area_vote'}
				<Structure bind:poll>
					<div slot="left"><AreaVote /></div>
					<div slot="right" class="!p-0"><Comments bind:proposals api="poll" /></div>
				</Structure>
				<!-- PHASE 2: PROPOSAL CREATION -->
			{:else if phase === 'proposal'}
				<Structure bind:poll>
					<div slot="left" class="h-full relative">
						<span class="text-center text-primary font-bold text-md"
							>All proposals ({proposals?.length})</span
						>
						<div class="max-h-[80%] overflow-y-scroll">
							<ProposalScoreVoting
								bind:proposals
								isVoting={false}
								bind:selectedProposal
								bind:phase
							/>
						</div>
						<Button
							Class="absolute bottom-0 w-full"
							buttonStyle="primary-light"
							action={() => (selectedProposal = null)}>Create Proposal</Button
						>
					</div>
					<div slot="right" class="">
						{#if selectedProposal}
							<!-- <Proposal
								bind:selectedProposal
								proposal={selectedProposal}
								isVoting={false}
								bind:phase
							/> -->
							<span class="text-primary font-bold block"> {selectedProposal.title}</span>
							<span>
								{selectedProposal.description}
							</span>
							<!-- {@debug selectedProposal} -->
							{#if selectedProposal.attachments}
								<div>
									{#each selectedProposal.attachments as file}
										<!-- svelte-ignore a11y-missing-attribute -->
										<img src={`${env.PUBLIC_API_URL}/media/${file.file}`} />
									{/each}
								</div>
							{/if}
						{:else}
							<ProposalSubmition bind:proposals {poll} />
						{/if}
					</div>
					<div slot="bottom"><Comments bind:proposals api="poll" /></div>
				</Structure>

				<!-- PHASE 3: PREDICTION STATEMENT CREATION -->
			{:else if phase === 'prediction_statement'}
				<Structure bind:poll>
					<div slot="left" class="h-full relative">
						<span class="text-center text-primary font-bold text-md"
							>All proposals ({proposals?.length})</span
						>
						<div class="max-h-[80%] overflow-y-scroll">
							<ProposalScoreVoting
								bind:proposals
								bind:phase
								bind:selectedProposal
								bind:proposalsToPredictionMarket
								isVoting={false}
							/>
						</div>
						<Button
							Class="w-full absolute bottom-0"
							buttonStyle="primary-light"
							action={() => (selectedProposal = null)}>Create Prediction</Button
						>
					</div>
					<div slot="right" class="relative">
						{#if selectedProposal}
							<Proposal
								bind:selectedProposal
								bind:phase
								proposal={selectedProposal}
								isVoting={false}
							/>
							<PredictionStatements bind:selectedProposal bind:phase bind:poll />
						{:else if proposalsToPredictionMarket.length === 0}
							<span class="text-center block text-primary font-semibold">
								To make a prediction, please select atleast one proposal
							</span>
						{:else}
							<Predictions bind:proposals bind:poll bind:proposalsToPredictionMarket />
						{/if}
					</div>

					<!-- <div slot="right"></div> -->
					<div slot="bottom"><Comments bind:proposals api="poll" /></div>
				</Structure>

				<!-- PHASE 4: PREDICTION BETTING -->
			{:else if phase === 'prediction_bet'}
				<Structure bind:poll>
					<div slot="left" class="">
						<span class="text-center text-primary font-bold text-md"
							>All proposals ({proposals?.length})</span
						>
						<div class="max-h-[80%] overflow-y-scroll">
							<ProposalScoreVoting
								bind:proposals
								isVoting={false}
								bind:phase
								bind:selectedProposal
							/>
						</div>
					</div>
					<div slot="right">
						{#if selectedProposal}
							<Proposal
								bind:selectedProposal
								bind:phase
								proposal={selectedProposal}
								isVoting={false}
							/>
							<PredictionStatements bind:selectedProposal bind:phase bind:poll />
						{/if}
					</div>
					<div slot="bottom"><Comments bind:proposals api="poll" /></div>
				</Structure>
				<!-- PHASE 5: DELEGATE VOTING -->
			{:else if phase === 'delegate_vote'}
				<Structure bind:poll>
					<div slot="left" class="">
						<span class="text-center text-primary font-bold text-md"
							>All proposals ({proposals?.length})</span
						>
						<div class="max-h-[90%] overflow-y-scroll">
							<ProposalScoreVoting
								bind:proposals
								isVoting={false}
								bind:phase
								bind:selectedProposal
							/>
						</div>
					</div>
					<div slot="right">
						{#if selectedProposal}
							<Proposal
								bind:selectedProposal
								bind:phase
								proposal={selectedProposal}
								isVoting={false}
							/>
							<PredictionStatements bind:selectedProposal bind:phase bind:poll />
						{/if}
					</div>
					<div slot="bottom"><Comments bind:proposals api="poll" /></div>
				</Structure>
				<!-- PHASE 6: ANYONE VOTING -->
			{:else if phase === 'vote'}
				<Structure bind:poll>
					<div slot="left" class="">
						<span class="text-center text-primary font-bold text-md"
							>All proposals ({proposals?.length})</span
						>
						<div class="max-h-[90%] overflow-y-scroll">
							<ProposalScoreVoting
								bind:proposals
								bind:phase
								bind:selectedProposal
								isVoting={false}
							/>
						</div>
					</div>
					<div slot="right">
						{#if selectedProposal}
							<Proposal
								bind:selectedProposal
								bind:phase
								proposal={selectedProposal}
								isVoting={false}
							/>
							<PredictionStatements bind:selectedProposal bind:phase bind:poll />
						{/if}
					</div>
					<div slot="bottom"><Comments bind:proposals api="poll" /></div>
				</Structure>
				<!-- PHASE 6: RESULTS -->
			{:else if phase === 'result' || phase === 'prediction_vote'}
				<Structure bind:poll>
					<div slot="left" class="">
						{#if proposals}
							<PredictionStatements selectedProposal={proposals[0]} bind:phase bind:poll />
						{/if}
					</div>
					<div slot="right"><Results bind:proposals {pollType} /></div>
					<div slot="bottom"><Comments bind:proposals api="poll" /></div>
				</Structure>
			{/if}
		{:else if pollType === 3}
			{#if !finished}
				<DatePoll />
			{:else}
				<Results {pollType} />
			{/if}
		{/if}

		<!-- Mod Tools -->
		<!-- TODO: Fix as part of svelte store information this place -->
		{#if groupUser?.is_admin}
			<StatusMessage bind:status={deleteStatus} />
			<div class="flex gap-4 align-middle">
				<div class="">Mod Tools:</div>
				<Button action={() => (DeletePollModalShow = true)} Class="bg-red-500 !inline"
					>{$_('Delete poll')}</Button
				>
				{#if !finished}
					<Button action={nextPhase}>Next Phase</Button>
				{/if}
			</div>
		{/if}
	{/if}
</Layout>

<Modal bind:open={DeletePollModalShow}>
	<div slot="header">{$_('Deleting Poll')}</div>
	<div slot="body">
		{$_('Are you sure you want to delete this poll?')}
	</div>
	<div slot="footer">
		<div class="flex justify-center gap-16">
			<Button action={deletePoll} Class="bg-red-500">{$_('Yes')}</Button><Button
				action={() => (DeletePollModalShow = false)}
				Class="bg-gray-400 w-1/2">{$_('Cancel')}</Button
			>
		</div>
	</div>
</Modal>

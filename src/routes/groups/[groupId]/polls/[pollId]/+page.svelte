<script lang="ts">
	import Comments from '$lib/Comments/Comments.svelte';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { Comment, Phase, poll, proposal } from '$lib/Poll/interface';
	import Button from '$lib/Generic/Button.svelte';
	import { _ } from 'svelte-i18n';
	import Results from '$lib/Poll/Results.svelte';
	import type { groupUser } from '$lib/Group/interface';
	import { checkForLinks } from '$lib/Generic/GenericFunctions';
	import ProposalSubmition from '$lib/Poll/ProposalSubmition.svelte';
	import Predictions from '$lib/Poll/PredictionMarket/PredictionCreate.svelte';
	import PollHeader from '$lib/Poll/PollHeader.svelte';
	import { getPhase } from '$lib/Poll/functions';
	import AreaVote from '$lib/Poll/AreaVote.svelte';
	import ProposalScoreVoting from '$lib/Poll/ProposalScoreVoting.svelte';
	import DatePoll from '$lib/Poll/DatePoll.svelte';
	import Structure from '$lib/Poll/NewDesign/Structure.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import PredictionStatements from '$lib/Poll/PredictionStatements.svelte';
	import { env } from '$env/dynamic/public';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import NewDescription from '$lib/Poll/NewDescription.svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';

	let poll: poll,
		pollType = 1,
		finished: boolean,
		groupUser: groupUser,
		phase: Phase,
		proposals: proposal[],
		selectedProposal: proposal | null,
		proposalsToPredictionMarket: proposal[] = [],
		poppup: poppup,
		displayForm: boolean,
		comments: Comment[] = [];

	onMount(async () => {
		getGroupUser();
		await getPollData();
		phase = getPhase(poll);
		scrollToSection();
		checkForLinks(poll?.description, 'poll-description');
		document.title = poll.title;
		getDisplayForm();
	});

	const getPollData = async () => {
		if (!$page.params) return;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/list?id=${$page.params.pollId}`
		);

		if (!res.ok) {
			poppup = { message: json.detail[0], success: false };
			return;
		}

		poll = json.results[0];
		pollType = json.results[0].poll_type;
		finished = new Date(json.results[0].end_date) < new Date();
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

	const getDisplayForm = () => {
		const display = $page.url.searchParams.get('display');
		console.log(display, 'IDS');

		if (display === null || display === undefined || display === '0') displayForm = false;
		if (display === '1') displayForm = true;
	};

	$: if (phase === 'proposal') {
		const a = setTimeout(() => {
			getPollData();
			clearTimeout(a);
		}, 2000);
	}
</script>

<Layout centered>
	{#if poll}
		{#if pollType === 4}
			<PollHeader {poll} bind:phase displayTag={phase !== 'area_vote' && phase !== 'pre_start'} />
		{:else}
			<PollHeader {poll} bind:phase displayTag={false} />
		{/if}

		{#if pollType === 4}
			<!-- PHASE 0: PRE-START -->
			{#if phase === 'pre_start'}
				<div class="bg-white shadow rounded mt-6 p-6">
					{$_('This poll will start at')}
					{formatDate(poll.start_date)}
				</div>
				<div class="bg-white p-6 mt-6">
					<Comments bind:_comments={comments} bind:proposals api={'poll'} />
				</div>

				<!-- PHASE 1: AREA VOTE -->
			{:else if phase === 'area_vote'}
				<Structure bind:phase bind:poll>
					<div slot="left"><AreaVote /></div>
					<div slot="right" class="!p-0">
						<Comments bind:_comments={comments} bind:proposals api={'poll'} />
					</div>
				</Structure>

				<!-- PHASE 2: PROPOSAL CREATION -->
			{:else if phase === 'proposal'}
				<Structure bind:phase bind:poll>
					<div slot="left" class="h-full relative">
						<span class="text-xl font-semibold mb-4 ml-3 text-primary dark:text-secondary"
							>{$_('Proposals')} ({proposals?.length})</span
						>
						<div class="max-h-[80%] overflow-y-auto">
							<ProposalScoreVoting
								bind:poll
								bind:selectedProposal
								bind:proposals
								bind:comments
								bind:phase
								isVoting={false}
							/>
						</div>
						<Button
							Class="w-full absolute bottom-0 mb-2"
							buttonStyle="primary-light"
							disabled={displayForm && !selectedProposal}
							onClick={() => {
								selectedProposal = null;
								displayForm = true;
							}}>{$_('Add Proposal')}</Button
						>
					</div>
					<div slot="right" class="relative h-full">
						{#if selectedProposal}
							<div class="flex flex-col space-y-2 p-2">
								<span
									class="text-primary text-lg dark:text-secondary font-semibold block break-words"
								>
									{selectedProposal.title}</span
								>
								<span class="break-words">
									{selectedProposal.description}
								</span>
							</div>
							{#if selectedProposal.attachments}
								<div>
									{#each selectedProposal.attachments as file}
										<img alt="attachment" src={`${env.PUBLIC_API_URL}/media/${file.file}`} />
									{/each}
								</div>
							{/if}
						{:else if displayForm}
							<ProposalSubmition {poll} bind:proposals bind:displayForm />
						{/if}
					</div>
					<div slot="bottom">
						<Comments bind:_comments={comments} bind:proposals api={'poll'} />
					</div>
				</Structure>

				<!-- PHASE 3: PREDICTION STATEMENT CREATION -->
			{:else if phase === 'prediction_statement'}
				<Structure bind:phase bind:poll>
					<div slot="left" class="h-full relative">
						<span class="text-xl font-semibold mb-4 ml-3 text-primary dark:text-secondary"
							>{$_('Proposals')} ({proposals?.length})</span
						>
						<div class="max-h-[80%] overflow-y-auto">
							<ProposalScoreVoting
								bind:poll
								bind:comments
								bind:proposals
								bind:phase
								bind:selectedProposal
								bind:proposalsToPredictionMarket
								isVoting={false}
							/>
						</div>
						<Button
							Class="w-full absolute bottom-0 mt-2"
							buttonStyle="primary-light"
							disabled={displayForm && !selectedProposal}
							onClick={() => {
								selectedProposal = null;
								displayForm = true;
							}}>{$_('Create Consequence')}</Button
						>
					</div>
					<div slot="right" class="relative h-full overflow-hidden">
						{#if selectedProposal}
							<div class="flex flex-col space-y-2 p-2">
								<div class="font-semibold text-primary dark:text-secondary text-lg">
									{selectedProposal.title}
								</div>
								<NewDescription
									description={selectedProposal.description}
									limit={2}
									lengthLimit={130}
								/>
								<PredictionStatements bind:selectedProposal bind:phase bind:poll />
							</div>
						{:else if proposalsToPredictionMarket.length === 0}
							<span class="text-center block text-primary dark:text-secondary font-semibold pt-4">
								{$_('To make a consequence, please select at least one proposal')}
							</span>
						{:else if displayForm}
							<Predictions bind:proposals bind:poll bind:proposalsToPredictionMarket />
						{/if}
					</div>
					<div slot="bottom">
						<Comments bind:_comments={comments} bind:proposals api={'poll'} />
					</div>
				</Structure>

				<!-- PHASE 4: PREDICTION BETTING -->
			{:else if phase === 'prediction_bet'}
				<Structure bind:phase bind:poll>
					<div slot="left" class="h-full">
						<span class="text-xl font-semibold mb-4 ml-3 text-primary dark:text-secondary"
							>{$_('Proposals')} ({proposals?.length})</span
						>
						<div class="max-h-full overflow-y-auto">
							<ProposalScoreVoting
								bind:poll
								bind:comments
								bind:proposals
								bind:phase
								bind:selectedProposal
								isVoting={false}
							/>
						</div>
					</div>
					<div slot="right">
						{#if selectedProposal}
							<div class="flex flex-col space-y-2 p-2">
								<div class="font-semibold text-primary dark:text-secondary text-lg">
									{selectedProposal.title}
								</div>
								<NewDescription
									description={selectedProposal.description}
									limit={2}
									lengthLimit={130}
								/>
								<PredictionStatements bind:selectedProposal bind:phase bind:poll />
							</div>
						{/if}
					</div>
					<div slot="bottom">
						<Comments bind:_comments={comments} bind:proposals api={'poll'} />
					</div>
				</Structure>

				<!-- PHASE 5: DELEGATE VOTING -->
			{:else if phase === 'delegate_vote'}
				<Structure bind:phase bind:poll>
					<div slot="left" class="h-full">
						<span class="text-xl font-semibold mb-4 ml-3 text-primary dark:text-secondary"
							>{$_('Proposals')} ({proposals?.length})</span
						>
						<div class="max-h-[90%] overflow-y-auto">
							<ProposalScoreVoting
								bind:comments
								bind:proposals
								isVoting={false}
								bind:phase
								bind:selectedProposal
								bind:poll
							/>
						</div>
					</div>
					<div slot="right">
						{#if selectedProposal}
							<div class="flex flex-col space-y-2 p-2">
								<div class="font-semibold text-primary dark:text-secondary text-lg">
									{selectedProposal.title}
								</div>
								<NewDescription
									description={selectedProposal.description}
									limit={2}
									lengthLimit={130}
								/>
								<PredictionStatements bind:selectedProposal bind:phase bind:poll />
							</div>
						{/if}
					</div>
					<div slot="bottom">
						<Comments bind:_comments={comments} bind:proposals api={'poll'} />
					</div>
				</Structure>
				<!-- PHASE 6: NON-DELEGATE VOTING -->
			{:else if phase === 'vote'}
				<Structure bind:phase bind:poll>
					<div slot="left" class="h-full">
						<span class="text-xl font-semibold mb-4 ml-3 text-primary dark:text-secondary"
							>{$_('Proposals')} ({proposals?.length})</span
						>
						<div class="max-h-[90%] overflow-y-auto">
							<ProposalScoreVoting
								bind:poll
								bind:comments
								bind:proposals
								bind:phase
								bind:selectedProposal
								isVoting={false}
							/>
						</div>
					</div>
					<div slot="right">
						{#if selectedProposal}
							<div class="flex flex-col space-y-2 p-2">
								<div class="font-semibold text-primary dark:text-secondary text-lg">
									{selectedProposal.title}
								</div>
								<NewDescription
									description={selectedProposal.description}
									limit={2}
									lengthLimit={130}
								/>
								<PredictionStatements bind:selectedProposal bind:phase bind:poll />
							</div>
						{/if}
					</div>
					<div slot="bottom">
						<Comments bind:_comments={comments} bind:proposals api={'poll'} />
					</div>
				</Structure>
				<!-- PHASE 7: RESULTS AND EVALUATION -->
			{:else if phase === 'result' || phase === 'prediction_vote'}
				<Structure bind:phase bind:poll>
					<div slot="left" class="h-full overflow-y-auto">
						{#if proposals}
							<PredictionStatements
								bind:phase
								bind:poll
								selectedProposal={proposals.sort((_proposal) => _proposal.score)[0]}
							/>
						{/if}
					</div>
					<div slot="right"><Results bind:poll {pollType} /></div>
					<div slot="bottom">
						<Comments bind:_comments={comments} bind:proposals api={'poll'} />
					</div>
				</Structure>
			{/if}
		{:else if pollType === 3}
			{#if !finished}
				<DatePoll />
			{:else}
				<Structure poll={null}>
					<div slot="left" class="w-[600px]">
						<Results bind:poll {pollType} />
					</div>

					<div slot="right"><Comments api="poll" /></div>
				</Structure>
			{/if}
		{/if}
	{/if}
</Layout>

<Poppup bind:poppup />

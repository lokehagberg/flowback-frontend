<script lang="ts">
	import Comments from '$lib/Comments/Comments.svelte';
	import { groupUserPermissionStore } from '$lib/Group/interface';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { Comment, Phase, poll, proposal } from '$lib/Poll/interface';
	import Button from '$lib/Generic/Button.svelte';
	import BackButton from '$lib/Generic/BackButton.svelte';
	import { _ } from 'svelte-i18n';
	import Results from '$lib/Poll/Results.svelte';
	import ProposalSubmition from '$lib/Poll/ProposalSubmition.svelte';
	import Predictions from '$lib/Poll/PredictionMarket/CreatePrediction.svelte';
	import PollHeader from '$lib/Poll/PollHeader.svelte';
	import { getPhase } from '$lib/Poll/functions';
	import AreaVote from '$lib/Poll/AreaVote.svelte';
	import ProposalScoreVoting from '$lib/Poll/ProposalScoreVoting.svelte';
	import DatePoll from '$lib/Poll/DatePoll.svelte';
	import Structure from '$lib/Poll/NewDesign/Structure.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import PredictionStatements from '$lib/Poll/PredictionStatements.svelte';
	import { env } from '$env/dynamic/public';
	import NewDescription from '$lib/Poll/NewDescription.svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import { predictionStatementsStore } from '$lib/Poll/PredictionMarket/interfaces';
	import Fa from 'svelte-fa';
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons';

	let poll: poll | null = $state(null),
		pollType = $state(1),
		finished: boolean = $state(false),
		phase: Phase = $state('pre_start'),
		proposals: proposal[] = $state([]),
		selectedProposal: proposal | null = $state(null),
		proposalsToPredictionMarket: proposal[] = $state([]),
		displayForm: boolean = $state(false),
		comments: Comment[] = $state([]),
		loading = $state(true),
		resetScroll = $state(false),
		showRightFormSlot = $state(false),
		showRightSlot = $state(false);

	const getPollData = async () => {
		if (!$page.params) return;
		loading = true;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/list?id=${$page.params.pollId}`
		);

		loading = false;

		if (!res.ok) return;

		poll = json?.results[0];
		pollType = json?.results[0]?.poll_type;
		finished = new Date(json?.results[0]?.end_date) < new Date();
	};

	const scrollToSection = () => {
		const section = $page.url.searchParams.get('section');
		if (!section) return;
		setTimeout(() => {
			const scrollTo = document.getElementById(section);
			scrollTo?.scrollIntoView({
				behavior: 'instant',
				block: 'start',
				inline: 'nearest'
			});
		}, 200);
	};

	const getDisplayForm = () => {
		const display = $page.url.searchParams.get('display');
		console.log(display, 'IDS');

		if (display === null || display === undefined || display === '0')
			displayForm = false;
		if (display === '1') displayForm = true;
	};

	const setUpPredictionStore = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/prediction/statement/list?poll_id=${$page.params.pollId}`
		);

		if (!res.ok) {
			return;
		}

		predictionStatementsStore.set(json?.results);
	};

	let setup = async () => {
		await getPollData();
		if (!poll) return;
		phase = getPhase(poll);
		scrollToSection();
		// checkForLinks(poll?.description, 'poll-description');
		document.title = poll?.title;
		getDisplayForm();
		setUpPredictionStore();
	};

	onMount(() => {
		setup();
	});

	// Fixes a bug where clicking between polls (because of links or in notification) doesn't update page properly
	$effect(() => {
		const { pollId } = $page.params;
		setup();
	});

	// When fast forwarding from area phase to proposal phase, get tag info in real time
	$effect(() => {
		if (phase === 'proposal') {
			const a = setTimeout(() => {
				getPollData();
				clearTimeout(a);
			}, 2000);
		}
	});

	$effect(() => {
		if (selectedProposal) resetScroll = true;
	});

	$effect(() => {
		showRightFormSlot = selectedProposal !== null || displayForm;
	});
	$effect(() => {
		showRightSlot = selectedProposal !== null;
	});
</script>

<Layout centered>
	{#if poll}
		{#if pollType === 4}
			<PollHeader
				{poll}
				bind:phase
				displayTag={phase !== 'area_vote' && phase !== 'pre_start'}
			/>
		{:else}
			<PollHeader {poll} bind:phase displayTag={false} />
		{/if}

		<!-- Normal Poll -->
		{#if pollType === 4}
			<!-- PHASE 0: PRE-START -->
			{#if phase === 'pre_start'}
				<div
					class="bg-white shadow rounded mt-6 p-6 dark:bg-darkobject dark:text-darkmodeText"
				>
					{$_('This poll will start at')}
					{formatDate(poll.start_date)}
				</div>
				<div class="dark:bg-darkobject bg-white p-6 mt-6">
					<Comments bind:proposals api={'poll'} />
				</div>

				<!-- PHASE 1: AREA VOTE -->
			{:else if phase === 'area_vote'}
				<Structure bind:phase bind:poll>
					<div slot="left" class="h-full"><AreaVote /></div>
					<div slot="bottom" class="!p-0">
						<Comments bind:proposals api={'poll'} />
					</div>
				</Structure>

				<!-- PHASE 2: PROPOSAL CREATION -->
			{:else if phase === 'proposal'}
				<Structure
					bind:phase
					bind:poll
					bind:resetScroll
					showRight={showRightFormSlot}
				>
					<div slot="left" class="h-full relative flex flex-col">
						<span
							class="text-xl font-semibold mb-4 ml-3 text-primary dark:text-secondary"
							>{$_('Proposals')} ({proposals?.length})</span
						>
						<div class="flex-grow overflow-y-auto mb-4">
							<ProposalScoreVoting
								bind:selectedProposal
								bind:proposals
								bind:comments
								bind:phase
							/>
						</div>
						<Button
							Class="w-full bottom-0 mt-auto"
							buttonStyle="primary-light"
							disabled={displayForm && !selectedProposal}
							onClick={() => {
								selectedProposal = null;
								displayForm = true;
							}}>{$_('Add Proposal')}</Button
						>
					</div>
					<div slot="right" class="relative h-full max-h-full overflow-y-auto">
						{#if selectedProposal}
							<BackButton
								bind:displayForm
								bind:selectedProposal
								bind:resetScroll
							/>
							<div class="flex flex-col p-2">
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
								<div class="">
									{#each selectedProposal.attachments as file}
										<img
											alt="attachment"
											src={`${env.PUBLIC_API_URL}/media/${file.file}`}
										/>
									{/each}
								</div>
							{/if}
						{:else if displayForm}
							<ProposalSubmition
								Class="max-h-full overflow-y-auto"
								{poll}
								bind:proposals
								bind:displayForm
							/>
						{/if}
					</div>
					<div slot="bottom">
						<Comments bind:proposals api={'poll'} />
					</div>
				</Structure>

				<!-- PHASE 3: PREDICTION STATEMENT CREATION -->
			{:else if phase === 'prediction_statement'}
				<Structure
					bind:phase
					bind:poll
					bind:resetScroll
					showRight={showRightFormSlot}
				>
					<div slot="left" class="relative h-full flex flex-col">
						<span
							class="text-xl font-semibold mb-4 ml-3 text-primary dark:text-secondary"
							>{$_('Proposals')} ({proposals?.length})</span
						>
						<div class="max-h-full overflow-y-auto mb-5">
							<ProposalScoreVoting
								bind:comments
								bind:proposals
								bind:phase
								bind:selectedProposal
								bind:proposalsToPredictionMarket
							/>
						</div>
						<Button
							Class="w-full mt-auto"
							buttonStyle="primary-light"
							disabled={proposalsToPredictionMarket.length === 0}
							onClick={() => {
								selectedProposal = null;
								displayForm = true;
							}}>{$_('Create Consequence')}</Button
						>
					</div>
					<div slot="right" class="relative h-full flex flex-col">
						{#if selectedProposal}
							<div class="flex flex-col space-y-2 p-2">
								<BackButton
									bind:displayForm
									bind:selectedProposal
									bind:resetScroll
								/>
								<div
									class="text-primary text-lg dark:text-secondary font-semibold block break-words"
								>
									{selectedProposal.title}
								</div>
								<NewDescription
									description={selectedProposal.description}
									limit={2}
									lengthLimit={130}
								/>
								<PredictionStatements
									bind:selectedProposal
									bind:phase
									bind:poll
								/>
							</div>
						{:else if proposalsToPredictionMarket.length === 0}
							<BackButton
								bind:displayForm
								bind:selectedProposal
								bind:resetScroll
							/>
							<span
								class="text-center block text-primary dark:text-secondary font-semibold pt-4"
							>
								{$_(
									'To make a consequence, please select at least one proposal'
								)}
							</span>
						{:else if displayForm}
							<Predictions
								bind:proposals
								bind:poll
								bind:proposalsToPredictionMarket
							/>
						{/if}
					</div>
					<div slot="bottom">
						<Comments bind:proposals api={'poll'} />
					</div>
				</Structure>

				<!-- PHASE 4: PREDICTION BETTING -->
			{:else if phase === 'prediction_bet'}
				<Structure
					bind:phase
					bind:poll
					bind:resetScroll
					showRight={showRightSlot}
				>
					<div slot="left" class="h-full">
						<span
							class="text-xl font-semibold mb-4 ml-3 text-primary dark:text-secondary"
							>{$_('Proposals')} ({proposals?.length})</span
						>
						<div class="max-h-[90%] overflow-y-auto">
							<ProposalScoreVoting
								{getPollData}
								bind:comments
								bind:phase
								bind:proposals
								bind:selectedProposal
							/>
						</div>
					</div>
					<div slot="right">
						{#if selectedProposal}
							<div class="flex flex-col space-y-2 p-2">
								<div
									class="text-primary text-lg dark:text-secondary font-semibold block break-words"
								>
									{selectedProposal.title}
								</div>
								<BackButton
									bind:displayForm
									bind:selectedProposal
									bind:resetScroll
								/>
								<NewDescription
									description={selectedProposal.description}
									limit={2}
									lengthLimit={130}
								/>
								<PredictionStatements
									{getPollData}
									bind:selectedProposal
									bind:phase
									bind:poll
								/>
							</div>
						{/if}
					</div>
					<div slot="bottom">
						<Comments bind:proposals api={'poll'} />
					</div>
				</Structure>

				<!-- PHASE 5: DELEGATE VOTING -->
			{:else if phase === 'delegate_vote'}
				<Structure
					bind:phase
					bind:poll
					bind:resetScroll
					showRight={showRightSlot}
				>
					<div slot="left" class="h-full">
						<span
							class="text-xl font-semibold mb-4 ml-3 text-primary dark:text-secondary"
							>{$_('Proposals')} ({proposals?.length})</span
						>
						<div class="max-h-[90%] overflow-y-auto">
							<ProposalScoreVoting
								bind:comments
								bind:proposals
								bind:phase
								bind:selectedProposal
							/>
						</div>
					</div>
					<div slot="right">
						{#if selectedProposal}
							<div class="flex flex-col space-y-2 p-2">
								<div
									class="text-primary text-lg dark:text-secondary font-semibold block break-words"
								>
									{selectedProposal.title}
								</div>
								<BackButton
									bind:displayForm
									bind:selectedProposal
									bind:resetScroll
								/>
								<NewDescription
									description={selectedProposal.description}
									limit={2}
									lengthLimit={130}
								/>
								<PredictionStatements
									bind:selectedProposal
									bind:phase
									bind:poll
								/>
							</div>
						{/if}
					</div>
					<div slot="bottom">
						<Comments bind:proposals api={'poll'} />
					</div>
				</Structure>

				<!-- PHASE 6: NON-DELEGATE VOTING -->
			{:else if phase === 'vote'}
				<Structure
					bind:phase
					bind:poll
					bind:resetScroll
					showRight={showRightSlot}
				>
					<div slot="left" class="h-full" id="proposals-section">
						<span
							class="text-xl font-semibold mb-4 ml-3 text-primary dark:text-secondary"
							>{$_('Proposals')} ({proposals?.length})</span
						>
						<div>
							{#if $groupUserPermissionStore?.allow_vote === true}
								{$_('You are allowed to vote')}
							{:else}
								{$_('You are not allowed to vote')}
							{/if}
						</div>
						<div class="max-h-[90%] overflow-y-auto">
							<ProposalScoreVoting
								bind:comments
								bind:proposals
								bind:selectedProposal
								bind:phase
							/>
						</div>
					</div>
					<div slot="right">
						{#if selectedProposal}
							<div class="flex flex-col space-y-2 p-2">
								<div
									class="text-primary text-lg dark:text-secondary font-semibold block break-words"
								>
									<BackButton
										bind:displayForm
										bind:selectedProposal
										bind:resetScroll
									/>
									{selectedProposal.title}
								</div>
								<NewDescription
									description={selectedProposal.description}
									limit={2}
									lengthLimit={130}
								/>
								<PredictionStatements
									bind:selectedProposal
									bind:phase
									bind:poll
								/>
							</div>
						{/if}
					</div>
					<div slot="bottom">
						<Comments bind:proposals api={'poll'} />
					</div>
				</Structure>

				<!-- PHASE 7: RESULTS AND EVALUATION -->
			{:else if phase === 'result' || phase === 'prediction_vote'}
				<Structure bind:phase bind:poll bind:resetScroll showBoth>
					<div slot="left" class="h-full overflow-y-auto">
						<PredictionStatements bind:selectedProposal bind:phase bind:poll />
					</div>
					<div slot="right">
						<Results bind:selectedProposal bind:poll {getPollData} {pollType} />
					</div>
					<div slot="bottom">
						<Comments bind:proposals api={'poll'} />
					</div>
				</Structure>
			{/if}

			<!-- Date Poll -->
		{:else if pollType === 3}
			{#if phase === 'result' || phase === 'prediction_vote'}
				<Structure bind:phase bind:poll showBoth>
					<div slot="left" class="w-full">
						<Results bind:poll {getPollData} {pollType} />
					</div>

					<div slot="right"><Comments api="poll" /></div>
					<DatePoll slot="bottom" Class="w-full" results />
				</Structure>
			{:else}
				<!-- Voting Phase -->
				<DatePoll Class="w-[100%] lg:w-[70%] md:p-6 max-w-[1000px]" />
			{/if}
		{/if}
	{:else if !loading}
		<div
			class="p-4 bg-white dark:bg-darkobject dark:text-darkmodeText mt-4 rounded shadow"
		>
			<p>{$_('No poll found, it might have been deleted')}</p>
			<Button onClick={() => history.back()}><Fa icon={faArrowLeft} /></Button>
		</div>
	{/if}
</Layout>

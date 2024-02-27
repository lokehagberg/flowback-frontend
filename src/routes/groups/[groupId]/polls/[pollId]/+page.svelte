<script lang="ts">
	import ProposalsRanked from '$lib/Poll/ProposalsRanked.svelte';
	import Timeline from '$lib/Poll/Timeline.svelte';
	import Comments from '$lib/Poll/Comments.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { Phase, poll, proposal, votings } from '$lib/Poll/interface';
	import Button from '$lib/Generic/Button.svelte';
	import Tab from '$lib/Generic/Tab.svelte';
	import { _ } from 'svelte-i18n';
	import Modal from '$lib/Generic/Modal.svelte';
	import Results from '$lib/Poll/Results.svelte';
	import ScheduledSubmission from '$lib/Poll/ScheduledSubmission.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import type { groupUser } from '$lib/Group/interface';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import { checkForLinks, type StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import ProposalSubmition from '$lib/Poll/ProposalSubmition.svelte';
	import Predictions from '$lib/Poll/PredictionMarket/Predictions.svelte';
	import TitleDescription from '$lib/Poll/TitleDescription.svelte';
	import { getPhase } from '$lib/Poll/functions';
	import AreaVote from '$lib/Poll/AreaVote.svelte';

	// TODO: refactor the phase system so be very modular
	//{#if phase === "phase x}
	//	 <PhaseX />
	// ...

	let poll: poll,
		votings: votings[],
		selectedPage: 'You' | 'Delegate' = 'You',
		abstained: proposal[],
		DeletePollModalShow = false,
		pollType = 1,
		finished: boolean,
		groupUser: groupUser,
		deleteStatus: StatusMessageInfo,
		phase: Phase,
		proposals: proposal[];

	onMount(async () => {
		getGroupUser();
		await getPollData();
		phase = getPhase(poll);
		scrollToSection();
		checkForLinks(poll.description, 'poll-description');
		document.title = poll.title;
	});

	const getPollData = async () => {
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
		if (res.ok) window.location.href = `/groups/${$page.params.groupId}`;
		else deleteStatus = statusMessageFormatter(res, json, '');
	};

	//TODO: Replace this later with some kind of svelte stores or local storage data
	const getGroupUser = async () => {
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
			scrollTo?.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' });
		}, 1500);
	};
</script>

{#if poll}
	<Layout centered>
		<div
			class="p-10 m-10 bg-white dark:bg-darkobject dark:text-darkmodeText rounded shadow pt-6 flex flex-col gap-8 w-full md:w-3/4 lg:w-2/3 lg:max-w-[1000px]"
		>
			<TitleDescription {pollType} {poll} />
			{$_('Current phase:')}
			{phase}

			{#if phase === 'pre-start'}
				<div>dev</div>
			{:else if phase === 'area-vote'}
			
				<AreaVote />
			
			{:else if phase === 'proposals'}
				<ProposalsRanked
					{groupUser}
					votingStartTime={poll.vote_start_date}
					pollType={poll.poll_type}
					tag={poll.tag}
					bind:phase
					bind:votings
					bind:selectedPage
					bind:abstained
					bind:proposals
				/>

				{#if pollType === 1}
					<!-- Ranked Poll -->
					<ProposalSubmition bind:abstained />
				{:else if pollType === 3}
					<!-- Scheduled Poll -->
					<ScheduledSubmission bind:abstained />
				{/if}
			{:else if phase === 'prediction-statement'}
				<ProposalsRanked
					{groupUser}
					votingStartTime={poll.vote_start_date}
					pollType={poll.poll_type}
					tag={poll.tag}
					bind:phase
					bind:votings
					bind:selectedPage
					bind:abstained
					bind:proposals
				/>
				<Predictions bind:proposals bind:phase />
			{:else if phase === 'prediction-betting'}
				<ProposalsRanked
					{groupUser}
					votingStartTime={poll.prediction_bet_end_date}
					pollType={poll.poll_type}
					tag={poll.tag}
					bind:phase
					bind:votings
					bind:selectedPage
					bind:abstained
					bind:proposals
				/>
				<Predictions bind:proposals bind:phase />
			{:else if phase === 'delegate-voting'}
				<Tab tabs={['You', 'Delegate']} bind:selectedPage />
				<ProposalsRanked
					{groupUser}
					votingStartTime={poll.prediction_bet_end_date}
					pollType={poll.poll_type}
					tag={poll.tag}
					bind:phase
					bind:votings
					bind:selectedPage
					bind:abstained
					bind:proposals
					delegatesCanVote
				/>
				<Predictions bind:proposals bind:phase />
			{:else if phase === 'voting'}
				<Tab tabs={['You', 'Delegate']} bind:selectedPage />
				<ProposalsRanked
					{groupUser}
					votingStartTime={poll.prediction_bet_end_date}
					pollType={poll.poll_type}
					tag={poll.tag}
					bind:phase
					bind:votings
					bind:selectedPage
					bind:abstained
					bind:proposals
					nonDelegatesCanVote
				/>
				<Predictions bind:proposals bind:phase />
			{:else if phase === 'results'}
				<Results {pollType} />
				<Predictions bind:proposals bind:phase />
			{:else if phase === 'prediction-voting'}
				<Results {pollType} />
				<Predictions bind:proposals bind:phase />
			{/if}

			<Timeline
				displayDetails={false}
				dates={[
					new Date(poll.start_date),
					new Date(poll.area_vote_end_date),
					new Date(poll.proposal_end_date),
					new Date(poll.prediction_statement_end_date),
					new Date(poll.prediction_bet_end_date),
					new Date(poll.delegate_vote_end_date),
					new Date(poll.end_date)
				]}
			/>
			<Comments bind:proposals api="poll" />
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
			{#if groupUser?.is_admin}
				<StatusMessage bind:status={deleteStatus} />
				<Button action={() => (DeletePollModalShow = true)} Class="bg-red-500"
					>{$_('Delete poll')}</Button
				>
			{/if}
		</div>
		{#if poll.attachments && poll.attachments.length > 0}
			<img
				class=""
				src={`${import.meta.env.VITE_API}api/media/${poll.attachments[0].file}` || ''}
				alt="attachment to the comment"
			/>
		{/if}
	</Layout>
{/if}

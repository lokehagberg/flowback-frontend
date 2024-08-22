<script lang="ts">
	import Timeline from '$lib/Poll/TimelineLegacy.svelte';
	import Comments from '$lib/Comments/Comments.svelte';
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
	import { getPhase, getPhaseUserFriendlyName } from '$lib/Poll/functions';
	import AreaVote from '$lib/Poll/AreaVote.svelte';
	import ProposalScoreVoting from '$lib/Poll/ProposalScoreVoting.svelte';
	import Fa from 'svelte-fa';
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import DatePoll from '$lib/Poll/DatePoll.svelte';
	import { env } from "$env/dynamic/public";

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

{#if poll}
	<Layout centered>
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<!-- svelte-ignore a11y-click-events-have-key-events -->
		<div
			class="cursor-pointer p-1 m-6 bg-white dark:bg-darkobject dark:text-darkmodeText rounded shadow flex flex-col gap-8 w-full md:w-3/4 lg:w-2/3 lg:max-w-[1000px]"
			on:click={() => goto(`/groups/${$page.params.groupId}`)}
		>
			<!-- NOTE: In +layout, rote folder, there are URL related behaviours which are affected by this. -->
			<Fa icon={faArrowLeft} />
		</div>
		<div
			class="p-10 bg-white dark:bg-darkobject dark:text-darkmodeText rounded shadow pt-6 flex flex-col gap-8 w-full md:w-3/4 lg:w-2/3 lg:max-w-[1000px]"
		>
			<TitleDescription {poll} displayTag={phase !== 'area_vote'} />
			{#if poll.attachments && poll.attachments.length > 0}
				<img
					src={`${env.PUBLIC_API}/api/media/${poll.attachments[0].file}` || ''}
					alt="attachment to the poll"
				/>
			{/if}

			<!-- Current Phase -->
			<div>
				{$_('Current phase:')}
				{getPhaseUserFriendlyName(phase)}
			</div>

			{#if pollType === 4}
				{#if phase === 'pre_start'}
					<div>dev</div>
				{:else if phase === 'area_vote'}
					<AreaVote />
				{:else if phase === 'proposal'}
					<ProposalScoreVoting bind:proposals {groupUser} isVoting={false} />
					<ProposalSubmition bind:proposals {poll} />
				{:else if phase === 'prediction_statement'}
					<ProposalScoreVoting bind:proposals {groupUser} isVoting={false} />
					<Predictions bind:proposals bind:phase bind:poll />
				{:else if phase === 'prediction_bet'}
					<ProposalScoreVoting {proposals} {groupUser} isVoting={false} />
					<Predictions bind:proposals bind:phase bind:poll />
				{:else if phase === 'delegate_vote'}
					<!-- <Tab tabs={['You', 'Delegate']} bind:selectedPage /> -->
					<ProposalScoreVoting {groupUser} isVoting={groupUser?.is_delegate} {proposals} />
					<Predictions bind:proposals bind:phase bind:poll />
				{:else if phase === 'vote'}
					<Tab tabs={['You', 'Delegate']} bind:selectedPage />
					<ProposalScoreVoting {groupUser} isVoting={true} {proposals} />
					<Predictions bind:proposals bind:phase bind:poll />
				{:else if phase === 'result'}
					<Results {pollType} />
					<Predictions bind:proposals bind:phase bind:poll />
				{:else if phase === 'prediction_vote'}
					<Results {pollType} />
					<Predictions bind:proposals bind:phase bind:poll />
				{/if}
			{:else if pollType === 3}
				{#if !finished}
					<DatePoll />
				{:else}
					<Results {pollType} />
				{/if}
			{/if}

			<Timeline
				displayDetails={false}
				dates={// If text poll, have all phases. Date polls have fewer phases to display
				poll.poll_type === 4
					? [
							new Date(poll.start_date),
							new Date(poll.area_vote_end_date),
							new Date(poll.proposal_end_date),
							new Date(poll.prediction_statement_end_date),
							new Date(poll.prediction_bet_end_date),
							new Date(poll.delegate_vote_end_date),
							new Date(poll.end_date)
					  ]
					: [new Date(poll.start_date), new Date(poll.end_date)]}
				{pollType}
			/>

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
		</div>
		{#if poll.attachments && poll.attachments.length > 0}
			<img
				class=""
				src={`${env.PUBLIC_API}api/media/${poll.attachments[0].file}` || ''}
				alt="attachment to the comment"
			/>
		{/if}
	</Layout>
{/if}

<script lang="ts">
	import ProposalSubmition from '../../../../lib/Poll/ProposalSubmition.svelte';
	import ProposalsRanked from '$lib/Poll/ProposalsRanked.svelte';
	import Timeline from '$lib/Poll/Timeline.svelte';
	import Comments from '$lib/Poll/Comments.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Tag from '$lib/Group/Tag.svelte';
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
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import type { groupUser } from '$lib/Group/interface';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import { faAlignLeft } from '@fortawesome/free-solid-svg-icons/faAlignLeft';

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
		phase = getPhase();
		scrollToSection();
	});

	const getPhase = (): Phase => {
		const now = new Date();
		if (now < new Date(poll?.start_date)) return 'pre-start';
		else if (now >= new Date(poll?.start_date) && now < new Date(poll?.proposal_end_date))
			return 'proposals';
		else if (
			now >= new Date(poll?.proposal_end_date) &&
			now < new Date(poll?.delegate_vote_end_date)
		)
			return 'delegate-voting';
		else if (now >= new Date(poll?.delegate_vote_end_date) && now < new Date(poll?.end_date))
			return 'voting';
		else return 'end';
	};

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
	<Layout centering={true}>
		<div
			class="p-10 m-10 bg-white rounded shadow pt-6 flex flex-col gap-8 w-full md:w-3/4 lg:w-2/3 lg:max-w-[1000px]"
		>
			<h1 class="text-left text-5xl p-4 mt-auto mb-auto">{poll.title}</h1>
			<div class="border border-gray-200 rounded p-4 whitespace-pre-wrap">
				{poll.description}
				<div class="flex h-8 justify-between">
					<div class="flex items-baseline">
						<Tag Class="w-32" tag={poll.tag_name} />
						{#if pollType === 1}
							<!-- TODO make it easy to change poll types e.t.c -->
							<HeaderIcon Class="p-2 pl-2 cursor-default" icon={faAlignLeft} text={'Text Poll'} />
						{:else if pollType === 3}
							<HeaderIcon
								Class="p-2 pl-2 cursor-default"
								icon={faCalendarAlt}
								text={'Scheduled Poll'}
							/>
						{/if}
						<a
							href={`/groups/${$page.params.groupId}`}
							class:hover:underline={poll.group_joined}
							class="text-black"
						>
							<img
								class="h-8 w-8 inline rounded-full"
								src={`${import.meta.env.VITE_API}${poll.group_image}`}
								alt="group thumbnail"
							/>
							<span class="inline">{poll.group_name}</span>
						</a>
					</div>
					<!-- <HeaderIcon Class="p-2 cursor-default" icon={faHourglass} text={'End date'} /> -->
					<NotificationOptions
						id={poll.id}
						api={`group/poll/${poll.id}`}
						categories={['poll', 'timeline']}
						labels={['Poll', 'Timeline']}
					/>
				</div>
			</div>
			{#if finished}
				<Results {pollType} />
			{:else}
				{#if new Date(poll.proposal_end_date) <= new Date()}
					<Tab tabs={['You', 'Delegate']} bind:selectedPage />
				{/if}
				<ProposalsRanked
					{groupUser}
					votingStartTime={poll.proposal_end_date}
					pollType={poll.poll_type}
					tag={poll.tag}
					bind:phase
					bind:votings
					bind:selectedPage
					bind:abstained
					bind:proposals
				/>
				<!-- TODO: Replace this if statement with phases -->
				{#if new Date(poll.proposal_end_date) >= new Date() && new Date(poll.start_date) <= new Date()}
					{#if pollType === 1}
						<!-- Ranked Poll -->
						<ProposalSubmition bind:abstained />
					{:else if pollType === 3}
						<!-- Scheduled Poll -->
						<ScheduledSubmission bind:abstained />
					{/if}
				{/if}
			{/if}
			<Timeline
				displayDetails={false}
				dates={[
					new Date(poll.start_date),
					new Date(poll.proposal_end_date),
					new Date(poll.delegate_vote_end_date),
					new Date(poll.end_date)
				]}
			/>
			<Comments bind:proposals />
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
	</Layout>
{/if}

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
	import type { poll, proposal, votings } from '$lib/Poll/interface';
	import Button from '$lib/Generic/Button.svelte';
	import Tab from '$lib/Generic/Tab.svelte';
	import { _ } from 'svelte-i18n';
	import Modal from '$lib/Generic/Modal.svelte';
	import Results from '$lib/Poll/Results.svelte';
	import ScheduledSubmission from '$lib/Poll/ScheduledSubmission.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import { faArrowUp } from '@fortawesome/free-solid-svg-icons/faArrowUp';
	import { faArrowDown } from '@fortawesome/free-solid-svg-icons/faArrowDown';
	import { faHourglass } from '@fortawesome/free-solid-svg-icons/faHourglass';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import type { groupUser } from '$lib/Group/interface';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';

	let poll: poll,
		votings: votings[],
		selectedPage: 'You' | 'Delegate' = 'You',
		abstained: proposal[],
		DeletePollModalShow = false,
		pollType = 1,
		finished: boolean,
		groupUser: groupUser,
		deleteStatus: StatusMessageInfo;

	onMount(async () => {
		getPollData();
		getGroupUser();
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
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/delete`
		);
		if (res.ok) window.location.href = `/groups/${$page.params.groupId}`;
		else deleteStatus = statusMessageFormatter(res, json, "")
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
</script>

{#if poll}
	<Layout centering={true}>
		<div
			class="p-10 m-10 bg-white rounded shadow pt-6 flex flex-col gap-8 w-full md:w-3/4 lg:w-2/3 lg:max-w-[1000px]"
		>
			<h1 class="text-left text-5xl p-4 mt-auto mb-auto">{poll.title}</h1>
			<NotificationOptions id={poll.id} api={`group/poll/${poll.id}`} categories={["poll", "timeline"]} labels={["Poll", "Timeline"]}  />
			<div class="border border-gray-200 rounded p-4 whitespace-pre-wrap">
				{poll.description}
				<Tag Class="w-32 mb-1 mt-1" tag={poll.tag_name} />
				<div class="flex h-8">
					{#if pollType === 1}
						<HeaderIcon
							Class="p-2 pl-0 cursor-default"
							icons={[faArrowUp, faArrowDown]}
							text={'Ranking'}
						/>
					{:else if pollType === 3}
						<HeaderIcon Class="p-2 pl-0 cursor-default" icon={faCalendarAlt} text={'Scheduled'} />
					{/if}
					<HeaderIcon Class="p-2 cursor-default" icon={faHourglass} text={'End date'} />
				</div>
			</div>
			{#if finished}
				<Results {pollType} />
			{:else}
				{#if new Date(poll.proposal_end_date) <= new Date()}
					<Tab tabs={['You', 'Delegate']} bind:selectedPage />
				{/if}
				<ProposalsRanked
					votingStartTime={poll.proposal_end_date}
					pollType={poll.poll_type}
					bind:votings
					bind:selectedPage
					bind:abstained
					tag={poll.tag}
				/>

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
				dates={[
					new Date(poll.start_date),
					new Date(poll.proposal_end_date),
					new Date(poll.delegate_vote_end_date),
					new Date(poll.end_date)
				]}
			/>
			{#if import.meta.env.VITE_MODE === 'DEV'}
				<!-- <Comments /> -->
			{/if}
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

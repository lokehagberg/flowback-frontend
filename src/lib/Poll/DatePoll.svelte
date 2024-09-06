<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { faCheck, faX } from '@fortawesome/free-solid-svg-icons';
	import { DateInput } from 'date-picker-svelte';
	import Fa from 'svelte-fa';
	import { page } from '$app/stores';
	import Proposal from './ProposalLegacy.svelte';
	import { onMount } from 'svelte';
	import { ScheduleXCalendar } from '@schedule-x/svelte';
	import '@schedule-x/theme-default/dist/index.css';
	import T from '$lib/Group/Creation/T.svelte';
	import {
		createCalendar,
		createViewDay,
		createViewWeek,
		createViewMonthGrid,
		createViewMonthAgenda
	} from '@schedule-x/calendar';
	import WeekView from '$lib/Generic/Schedules/WeekView.svelte';

	let open = false,
		date: Date,
		proposals: Proposal[] = [],
		daysFormatting = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'],
		votes: number[] = [];

	const calendarApp = createCalendar({
		views: [createViewWeek()],
		events: [
			{
				id: '1',
				title: 'Event 1',
				start: '2024-07-06',
				end: '2024-07-06'
			},
			{
				id: '2',
				title: 'Event 2',
				start: '2024-07-06 02:00',
				end: '2024-07-06 04:00'
			}
		]
	});

	let postProposal = async () => {
		let end_date = new Date(date);
		end_date.setHours(date.getHours() + 1);

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/proposal/create`,
			{
				start_date: date,
				end_date
			}
		);
	};

	let getProposals = async () => {
		const { res, json } = await fetchRequest('GET', `group/poll/${$page.params.pollId}/proposals`);

		proposals = json.results;
	};

	let getProposalVote = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposal/votes`
		);

		votes = json.results.map((vote: any) => vote.proposal);
	};

	let updateProposalVote = async (id: number, adding: boolean) => {
		if (adding && !votes.find((vote) => vote === id)) votes.push(id);
		else votes = votes.filter((vote) => vote !== id);
		votes = votes;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/proposal/vote/update`,
			{ proposals: votes }
		);
	};

	let handlePostProposal = async () => {
		await postProposal();
		getProposals();
	};

	onMount(() => {
		getProposals();
		getProposalVote();
	});
</script>

<div class="flex">
	{#each proposals as proposal}
		{@const hasVoted = votes.find((vote) => vote === proposal.id)}
		<div class="flex flex-col p-2">
			<div class="text-center">{daysFormatting[new Date(proposal.start_date).getDay()]}</div>
			<div class="font-bold text-center">
				{new Date(proposal.start_date).getFullYear()}-{new Date(
					proposal.start_date
				).getMonth()}-{new Date(proposal.start_date).getDate()}
			</div>
			<div class="text-center">
				{new Date(proposal.start_date).getHours()}:{new Date(proposal.start_date).getMinutes()}
			</div>

			<div class="flex flex-col items-center rounded-none">
				<Button
					Class={`flex justify-center w-[90%] rounded-none ${
						hasVoted ? 'bg-green-300' : 'bg-red-300'
					}`}
					action={() => updateProposalVote(proposal.id, true)}
				>
					{#if hasVoted}
						<Fa icon={faCheck} />
					{:else}
						<Fa icon={faX} />
					{/if}
				</Button>
				<!-- <Button
					Class="flex justify-center w-[90%] rounded-none"
					buttonStyle="secondary"
					action={() => updateProposalVote(proposal.id, false)}><Fa icon={faX} /></Button
				> -->
			</div>
		</div>
	{/each}
</div>

<Button action={() => (open = true)}>New Proposal</Button>

<Modal bind:open onSubmit={handlePostProposal}>
	<div slot="body" class="min-w-[400px] min-h-[300px]">
		<DateInput bind:value={date} />
	</div>
	<div slot="footer">
		<Button type="submit">Submit</Button>
	</div>
</Modal>

<WeekView x={7} y={23} >
	
</WeekView>

<!-- <ScheduleXCalendar {calendarApp} eventModal={T} /> -->

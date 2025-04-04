<!-- NOTE: This "WeekView" file is (at the time of writing this comment) exclusively for DatePoll
	TODO: Extend to Schedule more generally and separate things for the datepoll API.
-->

<script lang="ts">
	import { faCheck, faChevronLeft, faChevronRight } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import Loader from '../Loader.svelte';
	import type { timeProposal } from '$lib/Poll/interface';
	import Button from '$lib/Generic/Button.svelte';
	import { ProposalsApi } from '$lib/api/proposals';

	export let x = 10,
		y = 10,
		votes: number[],
		proposals: timeProposal[];

	let weekOffset = 0;
	let initialMonday: Date;
	let loading = false;
	let selectedDates: Date[] = [];
	let weekDates: Date[] = [];
	let currentMonth = '';
	let currentYear = 0;
	let noChanges = true;

	const pollId = $page.params.pollId;

	// Date utility functions
	const getRecentMonday = (d: Date) => {
		const mondayOffset = d.getDate() - d.getDay() + 1;
		const month = mondayOffset < 0 ? d.getMonth() - 1 : d.getMonth();
		return new Date(d.getFullYear(), month, mondayOffset);
	};

	const getMondayForOffset = (offset: number): Date => {
		const today = new Date();
		const daysSinceMonday = today.getDay() === 0 ? 6 : today.getDay() - 1;
		const monday = new Date(today);
		monday.setDate(today.getDate() - daysSinceMonday + offset * 7);
		monday.setHours(0, 0, 0, 0);
		return monday;
	};

	// Data fetching and manipulation
	async function saveSelection() {
		loading = true;
		try {
			const validSelectedDates = selectedDates.filter((date): date is Date => date instanceof Date);
			let voteIds: number[] = [];

			for (const date of validSelectedDates) {
				const existingProposal = proposals.find(proposal => {
					const proposalDate = new Date(proposal.start_date);
					return proposalDate.getTime() === date.getTime();
				});

				if (existingProposal) {
					voteIds.push(existingProposal.id);
				} else {
					const end_date = new Date(date.getTime() + 60 * 60 * 1000);
					const newProposalId = await ProposalsApi.createProposal(pollId, { start_date: date, end_date });
					voteIds.push(newProposalId);
				}
			}

			await ProposalsApi.updateVotes(pollId, voteIds);
			votes = voteIds;
			const response = await ProposalsApi.getProposals(pollId);
			proposals = response.results;
			selectedDates = validSelectedDates;
			noChanges = true;
		} catch (error) {
			console.error('Error saving selection:', error);
		} finally {
			loading = false;
		}
	}

	// UI interaction handlers
	const clearSelection = () => {
		selectedDates = [];
		noChanges = false;
	};

	const toggleDate = (date: Date) => {
		if (!(date instanceof Date)) return;
		
		selectedDates = isSelected(date) 
			? selectedDates.filter(d => d.getTime() !== date.getTime())
			: [...selectedDates, date];
		noChanges = false;
	};

	const isSelected = (date: Date) => 
		selectedDates.some((_date) => _date?.getTime() === date?.getTime());

	// Navigation
	const prevWeek = () => weekOffset--;
	const nextWeek = () => weekOffset++;

	// Constants
	const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
	const months = [
		'January', 'February', 'March', 'April', 'May', 'June',
		'July', 'August', 'September', 'October', 'November', 'December'
	];

	// Reactive declarations
	$: {
		const monday = getMondayForOffset(weekOffset);
		weekDates = Array.from({ length: 7 }, (_, i) => {
			const date = new Date(monday);
			date.setDate(monday.getDate() + i);
			return date;
		});
		const middleOfWeek = weekDates[3];
		currentMonth = months[middleOfWeek.getMonth()];
		currentYear = middleOfWeek.getFullYear();
	}

	$: monday = getRecentMonday(
		new Date(
			initialMonday?.getFullYear(),
			initialMonday?.getMonth(),
			initialMonday?.getDate() + weekOffset * 7
		)
	);

	$: gridDates = Array.from({ length: y }, (_, j) =>
		Array.from(
			{ length: x },
			(_, i) => new Date(monday?.getFullYear(), monday?.getMonth(), monday?.getDate() + i, j)
		)
	);

	$: if (!initialMonday) {
		initialMonday = getRecentMonday(new Date());
	}

	$: if (votes && proposals) {
		const votedProposals = proposals.filter(proposal => 
			proposal?.id && votes.includes(proposal.id)
		);
		
		selectedDates = votedProposals
			.map(proposal => proposal?.start_date ? new Date(proposal.start_date) : null)
			.filter((date): date is Date => date instanceof Date);
	}
</script>

<Loader bind:loading>
	<div class="flex items-center justify-between border-b border-gray-300 py-1 px-4">
		<button on:click={prevWeek}><Fa icon={faChevronLeft} /></button>
		{currentMonth}
		{currentYear}
		(CET)
		<button on:click={nextWeek}><Fa icon={faChevronRight} /></button>
	</div>

	<div class="relative w-full">
		<div
			class="grid w-full text-sm text-center h-[500px] overflow-y-auto overflow-x-hidden"
			style={`grid-template-columns: repeat(${x + 1}, 1fr); grid-template-rows: repeat(${
				y + 1
			}, 1fr);`}
			id="weekView"
		>
			<div />
			{#each weekDates as date, i}
				<div class="flex flex-col items-center">
					<div class="font-semibold pt-2">{date.getDate()}</div>
					<div class="text-gray-600">{$_(weekdays[i])}</div>
				</div>
			{/each}

			<!-- {@debug selectedDates} -->
			{#each gridDates as row, j}
				<div class="bg-primary text-white flex justify-center px-0.5">{j}:00</div>
				{#each row as date, i}
					<button class="border h-12 w-24" on:click={() => toggleDate(date)}>
						{#if selectedDates.find((_date) => _date?.getTime() === date?.getTime())}
							<div class="bg-green-600 h-full w-full flex items-center justify-center">
								<Fa icon={faCheck} color="white" size="2x" />
							</div>
						{:else}
							<slot {i} {j} />
						{/if}
					</button>
				{/each}
			{/each}
		</div>

		<div class="pt-4 px-4 border-t flex gap-4 bg-white">
			<Button
				bind:disabled={noChanges}
				onClick={saveSelection}
				buttonStyle="primary-light"
				Class="flex-1">{$_('Submit')}</Button
			>
			<Button 
				onClick={clearSelection} 
				buttonStyle="warning-light" 
				disabled={selectedDates.length === 0}
				Class="flex-1">{$_('Clear')}</Button
			>
		</div>
	</div></Loader
>

<style>
	.calendar {
		display: grid;
		grid-template-columns: repeat(7, 1fr);
		grid-template-rows: repeat(6, 1fr);
		/* 100vh to stretch the calendar to the bottom, then we subtract 2 rem from the padding
    on the header, 40px from the height of each symbol/the logo on the header, and 
    28 px for the controlls on the calendar. This scuffed solution might need to be improved 
	
	TODO: Don't do this*/
		height: calc(100vh - 2rem - 40px - 28px);
	}
</style>

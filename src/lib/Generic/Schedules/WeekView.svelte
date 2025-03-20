<!-- NOTE: This "WeekView" file is (at the time of writing this comment) exclusively for DatePoll
	TODO: Extend to Schedule more generally and separate things for the datepoll API.
-->

<script lang="ts">
	import { faCheck, faChevronLeft, faChevronRight } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import Loader from '../Loader.svelte';
	import type { proposal, timeProposal } from '$lib/Poll/interface';
	import Button from '$lib/Generic/Button.svelte';
	import Proposal from '$lib/Poll/Proposal.svelte';

	export let x = 10,
		y = 10,
		votes: number[],
		proposals: timeProposal[] = [];
	// w = 200,
	// h = 300;

	let weekOffset: number = 0,
		initialMonday: Date,
		monday: Date,
		loading = false,
		// proposals: timeProposal[],
		selectedDates: Date[] = [],
		weekDates: Date[] = [],
		currentMonth = '',
		currentYear = 0,
		noChanges = true;

	const getRecentMonday = (d: Date) => {
		let mondayOffset = d.getDate() - d.getDay() + 1;
		let month = mondayOffset < 0 ? d.getMonth() - 1 : d.getMonth();

		return new Date(d.getFullYear(), month, mondayOffset);
	};

	// const toggleDate = (date: Date) => {
	// 	const before = selectedDates.find((_date) => _date?.getTime() === date?.getTime());
	// 	if (before)
	// 		selectedDates = selectedDates.filter((_date) => _date?.getTime() !== date?.getTime());
	// 	else selectedDates.push(date);

	// 	selectedDates = selectedDates;
	// };

	const getProposals = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposals?limit=10000`
		);

		proposals = json.results;
	};

	const getProposalVote = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposal/votes?limit=10000`
		);

		votes = json.results.map((vote: any) => vote.proposal);
		// selectedDates = votes;
	};

	const saveSelection = async () => {
		const array = selectedDates.map(async (date) => {
			const start_date = date;
			const end_date = new Date(
				date.getFullYear(),
				date.getMonth(),
				date.getDate(),
				date.getHours() + 1
			);

			const existingProposal = proposals.find(
				(proposal) => new Date(proposal.end_date).getTime() === end_date.getTime()
			);

			console.log(existingProposal, 'EXi');

			let resC, jsonC;
			if (!existingProposal) {
				const { res, json } = await fetchRequest(
					'POST',
					`group/poll/${$page.params.pollId}/proposal/create`,
					{
						start_date,
						end_date
					}
				);
				resC = res;
				jsonC = json;
			}

			console.log('hiello?');

			const { res, json } = await fetchRequest(
				'POST',
				`group/poll/${$page.params.pollId}/proposal/vote/update`,
				{
					proposals: [existingProposal ? existingProposal?.id : jsonC]
				}
			);
		});

		let output = await Promise.allSettled(array);
		loading = false;
		noChanges = true;
	};

	const dateOffset = (offset: number) => {
		let _date = new Date(monday.getTime());
		_date.setDate(monday.getDate() + offset);
		return _date.getDate();
	};

	const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
	const months = [
		'January',
		'February',
		'March',
		'April',
		'May',
		'June',
		'July',
		'August',
		'September',
		'October',
		'November',
		'December'
	];

	const clearSelection = () => {
		selectedDates = [];
		noChanges = true;
	};

	const getMondayForOffset = (offset: number): Date => {
		const today = new Date();
		const todayDay = today.getDay();
		const daysSinceMonday = todayDay === 0 ? 6 : todayDay - 1; // Söndag är 0
		const monday = new Date(today);
		monday.setDate(today.getDate() - daysSinceMonday + offset * 7);
		monday.setHours(0, 0, 0, 0);
		return monday;
	};

	const getWeekDates = (monday: Date): Date[] => {
		return Array.from({ length: 7 }, (_, i) => {
			const date = new Date(monday);
			date.setDate(monday.getDate() + i);
			return date;
		});
	};

	const getMonthAndYear = (weekDates: Date[]): { month: string; year: number } => {
		const middleOfWeek = weekDates[3];
		return {
			month: months[middleOfWeek.getMonth()],
			year: middleOfWeek.getFullYear()
		};
	};

	const prevWeek = () => {
		weekOffset--;
	};

	const nextWeek = () => {
		weekOffset++;
	};

	const isSelected = (date: Date) => {
		return selectedDates.find((_date) => _date?.getTime() === date?.getTime());
	};

	const toggleDate = (date: Date) => {
		if (isSelected(date)) {
			selectedDates = selectedDates.filter((d) => d.getTime() !== date.getTime());
		} else {
			selectedDates = [...selectedDates, date];
		}
		noChanges = false;
	};

	const transformVotesIntoSelectedDates = () => {
		if (votes.length === 0) return;
		const prop = proposals;
		const propFiltered = prop.filter((proposal) => votes.find((vote) => vote === proposal?.id));
		selectedDates = propFiltered.map((proposal) => new Date(proposal.end_date));
	};

	onMount(() => {
		// getProposals();
		// getProposalVote();
		initialMonday = getRecentMonday(new Date());
		transformVotesIntoSelectedDates();

		//TODO: Fix this reactivity mess
		const a = setTimeout(() => {
			transformVotesIntoSelectedDates();
			clearInterval(a);
		}, 200);
	});

	$: if (votes && selectedDates) {
		// transformVotesIntoSelectedDates();
	}

	$: {
		const monday = getMondayForOffset(weekOffset);
		weekDates = getWeekDates(monday);
		const { month, year } = getMonthAndYear(weekDates);
		currentMonth = month;
		currentYear = year;
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
</script>

<Loader bind:loading Class="flex flex-col">
	<div class="flex items-center justify-between border-b border-gray-300 py-1 px-4">
		<button on:click={prevWeek}><Fa icon={faChevronLeft} /></button>
		{currentMonth}
		{currentYear}
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
				<div class="bg-primary text-white items-center flex justify-center px-0.5">{j}</div>
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
			<Button onClick={clearSelection} buttonStyle="warning-light" Class="flex-1"
				>{$_('Cancel')}</Button
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

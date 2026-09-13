<!-- NOTE: This "WeekView" file is (at the time of writing this comment) exclusively for DatePoll
	TODO: Extend to Schedule more generally and separate things for the datepoll API.
-->

<script lang="ts">
	import {
		faChevronLeft,
		faChevronRight
	} from '@fortawesome/free-solid-svg-icons';
	import { faCheck } from '@fortawesome/free-solid-svg-icons/faCheck';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/state';
	import Loader from '../Loader.svelte';
	import type { timeProposal } from '$lib/Poll/interface';
	import Button from '$lib/Generic/Button.svelte';
	import { ProposalsApi } from '$lib/api/proposals';
	import { ErrorHandlerStore } from '../ErrorHandlerStore';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import { arraysEqual } from '$lib/Generic/GenericFunctions';
	import { isMobile } from '$lib/utils/isMobile';

	export let x = 10,
		y = 10,
		proposals: timeProposal[],
		results = false;

	let weekOffset = 0,
		initialMonday: Date,
		loading = false,
		// Saved dates are ones which the user has currently selected, while selected dates are ones which are saved in the databse.
		savedDates: SelDate[] = [],
		selectedDates: SelDate[] = [],
		weekDates: Date[] = [],
		currentMonth = '',
		currentYear = 0,
		noChanges = true;

	type SelDate = { date: Date; id: number; numOfVotes: number };
	const pollId = page.params.pollId;

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

	async function fetchProposals() {
		const response = await ProposalsApi.getProposals(pollId ?? '');
		proposals = response.results;
	}

	async function fetchProposalVotes() {
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/${pollId}/proposal/votes?limit=10000`
		);

		// Saved dates are meant to match tbe backend, while selected dates matches what the user has selected in the frontend
		savedDates = json.results.map((vote: any) => ({
			id: vote.proposal,
			date: new Date(
				proposals.find((proposal) => proposal.id === vote.proposal)
					?.start_date ?? ''
			)
		}));

		selectedDates = savedDates;
	}

	async function saveSelection() {
		if (!pollId) return;

		loading = true;
		let voteIds: number[] = [];

		for (const selectedDate of selectedDates) {
			const existingProposal = proposals.find((proposal) => {
				const proposalDate = new Date(proposal.start_date);
				return proposalDate.getTime() === selectedDate.date.getTime();
			});

			if (existingProposal) {
				voteIds.push(existingProposal.id);
			} else {
				const end_date = new Date(selectedDate.date.getTime() + 60 * 60 * 1000);

				const { res, json } = await fetchRequest(
					'POST',
					`group/poll/${pollId}/proposal/create`,
					{
						start_date: selectedDate.date,
						end_date
					}
				);

				if (!res.ok) {
					ErrorHandlerStore.set({
						message: "Couldn't save some dates",
						success: false
					});
					continue;
				}

				const newProposalId = json;
				voteIds.push(newProposalId);
			}
		}

		try {
			await ProposalsApi.updateVotes(pollId, voteIds);
			const { results } = await ProposalsApi.getProposals(pollId);
			proposals = results;
		} catch (error) {
			ErrorHandlerStore.set({
				message: "Couldn't save selections",
				success: false
			});
			loading = false;
			return;
		}

		savedDates = selectedDates;
		noChanges = true;
		loading = false;
		ErrorHandlerStore.set({
			message: 'Successfully saved selections',
			success: true
		});
	}

	// Triggers when user clicks "Clear" button
	const clearSelection = () => {
		selectedDates = [];
		noChanges = false;
	};

	// Triggers when user clicks a date cell
	const toggleDate = (date: Date) => {
		const cellPreviouslySelected = selectedDates.find(
			(_date) => _date?.date.getTime() === date?.getTime()
		);

		// If date is already selected, remove it; otherwise add it
		if (cellPreviouslySelected) {
			selectedDates = selectedDates.filter(
				(d) => d.date.getTime() !== date.getTime()
			);
		} else {
			selectedDates = [
				...selectedDates,
				{
					id:
						proposals.find(
							(p) => new Date(p.start_date).getTime() === date.getTime()
						)?.id ?? 0,
					date,
					numOfVotes: 1
				}
			];
		}

		noChanges = false;
	};

	// Navigation
	const prevWeek = () => weekOffset--;
	const nextWeek = () => weekOffset++;

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

	onMount(async () => {
		await fetchProposals();
		await fetchProposalVotes();
	});

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
			(_, i) =>
				new Date(
					monday?.getFullYear(),
					monday?.getMonth(),
					monday?.getDate() + i,
					j
				)
		)
	);

	$: if (!initialMonday) {
		initialMonday = getRecentMonday(new Date());
	}

	$: if (selectedDates === savedDates) {
		noChanges = true;
	} else {
		noChanges = false;
	}

	$: maxScore = Math.max(...proposals.map((p) => p.preliminary_score ?? 0), 1);

	const isToday = (date: Date) => date.toDateString() === new Date().toDateString();
</script>

<Loader bind:loading>
	<div class="overflow-x-auto">
		<div
			class={`sticky z-20 ${results ? 'md:-top-[1rem]' : 'top-0 md:top-[5.5rem]'}`}
		>
			<div
				class="dark:bg-darkobject dark:text-darkmodeText bg-white flex items-center justify-between mt-4 py-3 px-4 md:py-2"
			>
				<button
					class="rounded-full p-2 hover:bg-gray-100 dark:hover:bg-white/10 transition-colors"
					on:click={prevWeek}
					aria-label={$_('Previous week')}><Fa icon={faChevronLeft} /></button
				>
				<span class="font-semibold">{currentMonth} {currentYear}</span>
				<button
					class="rounded-full p-2 hover:bg-gray-100 dark:hover:bg-white/10 transition-colors"
					on:click={nextWeek}
					aria-label={$_('Next week')}><Fa icon={faChevronRight} /></button
				>
			</div>
			<div
				class="dark:bg-darkobject dark:text-darkmodeText bg-white grid text-center border-b border-gray-200 dark:border-gray-700/60 py-1"
				style={`grid-template-columns: minmax(3rem, 1fr) repeat(${x}, minmax(3.5rem, 1fr)); min-width: ${(x + 1) * 3.5}rem`}
			>
				<div class="sticky left-0 bg-white dark:bg-darkobject"></div>
				{#each weekDates as date, i}
					<div
						class="flex flex-col items-center py-1 {$isMobile ? 'text-xs' : ''}
						{isToday(date) ? 'text-accent dark:text-accent-secondary font-bold' : ''}"
					>
						<div class="font-semibold">{date.getDate()}</div>
						<div class="text-gray-500 dark:text-gray-400">{$_(weekdays[i])}</div>
					</div>
				{/each}
			</div>
		</div>
		<div
			class="grid w-full text-sm text-center"
			style={`grid-template-columns: minmax(3rem, 1fr) repeat(${x}, minmax(3.5rem, 1fr)); grid-template-rows: repeat(${y}, 1fr); min-width: ${(x + 1) * 3.5}rem`}
			id="weekView"
		>
			{#each gridDates as row, j}
				<div
					class="sticky left-0 z-10 bg-primary text-white flex justify-center items-center px-0.5
					{$isMobile ? 'text-xs' : ''}"
				>
					{j}:00
				</div>
				{#each row as date, i}
					{@const proposal = proposals.find(
						(p) => new Date(p.start_date).getTime() === date.getTime()
					)}
					{@const isSelected = !!selectedDates.find(
						(_date) => _date.date.getTime() === date?.getTime()
					)}
					{@const score = (() => {
						// This function allows for real-time updating
						// as the user is clicking on the dates.
						let s = proposal?.preliminary_score ?? 0;

						if (
							savedDates.find((s) => s.date.valueOf() === date.valueOf()) &&
							!selectedDates.find((s) => s.date.valueOf() === date.valueOf())
						)
							s -= 1;
						else if (
							!savedDates.find((s) => s.date.valueOf() === date.valueOf()) &&
							selectedDates.find((s) => s.date.valueOf() === date.valueOf())
						)
							s += 1;

						return s;
					})()}
					{@const heat = score > 0 ? 0.12 + 0.5 * (score / maxScore) : 0}

					<button
						class={`relative bg-white dark:bg-darkobject border border-gray-200 dark:border-gray-700/60 h-12 w-full transition-colors ${results ? 'cursor-default' : 'cursor-pointer hover:brightness-[0.97] dark:hover:brightness-110'}`}
						style={heat > 0 ? `background-color: rgba(1, 91, 192, ${heat})` : ''}
						on:click={() => {
							if (!results) toggleDate(date);
						}}
					>
						{#if score > 0}
							<span
								class="absolute top-0.5 right-0.5 min-w-[1.1rem] rounded-full bg-primary px-1 text-[10px] font-semibold leading-[1.1rem] text-white"
							>
								{score}
							</span>
						{/if}

						{#if isSelected}
							<span class="absolute inset-0 flex items-center justify-center">
								<Fa icon={faCheck} class="text-accent dark:text-accent-secondary" />
							</span>
						{:else}
							<slot {i} {j} />
						{/if}
					</button>
				{/each}
			{/each}
		</div>
	</div>
	<div class="p-4 border-t flex gap-4 bg-white dark:bg-darkobject">
		{#if !results}
			<Button
				disabled={arraysEqual(
					selectedDates.map((d) => d.date.getTime()).sort(),
					savedDates.map((d) => d.date.getTime()).sort()
				)}
				onClick={saveSelection}
				buttonStyle="primary-light"
				Class="flex-1">{$_('Submit')}</Button
			>
			<Button
				onClick={clearSelection}
				buttonStyle="warning-light"
				disabled={selectedDates.length === 0}
				Class="flex-1 disabled:!text-gray-300">{$_('Clear')}</Button
			>
		{/if}
	</div>
</Loader>

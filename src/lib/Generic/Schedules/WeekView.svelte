<script lang="ts">
	import { faCheck, faChevronLeft, faChevronRight } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import { getMonday, getWeek } from '../Dates';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { deepCopy } from '../GenericFunctions';

	export let x = 10,
		y = 10;
	// w = 200,
	// h = 300;

	let selectedDates: Date[] = [],
		weekOffset: number = 0,
		year: number = new Date().getFullYear(),
		initialMonday: Date,
		monday: Date;

	onMount(() => {
		initialMonday = getRecentMonday(new Date());
	});

	const getRecentMonday = (d: Date) => {
		let mondayOffset = d.getDate() - d.getDay() + 1;
		let month = mondayOffset < 0 ? d.getMonth() - 1 : d.getMonth();

		return new Date(d.getFullYear(), month, mondayOffset);
	};

	const toggleDate = (date: Date) => {
		const before = selectedDates.find((_date) => _date?.getTime() === date?.getTime());
		if (before)
			selectedDates = selectedDates.filter((_date) => _date?.getTime() !== date?.getTime());
		else selectedDates.push(date);

		selectedDates = selectedDates;
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

			try {
				const { res, json } = await fetchRequest(
					'POST',
					`group/poll/${$page.params.pollId}/proposal/create`,
					{
						start_date,
						end_date
					}
				);
			} catch {
				const { res, json } = await fetchRequest(
					'POST',
					`group/poll/${$page.params.pollId}/proposal/vote/update`,
					{
						start_date,
						end_date
					}
				);
			}
		});

		let output = await Promise.allSettled(array);
	};

	const dateOffset = (offset: number) => {

		let _date = new Date(monday.getTime());
		_date.setDate(monday.getDate() + offset);
		return _date.getDate();
	};

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

<!-- <button on:click={() => year++}>year up</button>
<button on:click={() => year--}>year down</button> -->
<button on:click={() => weekOffset--}><Fa icon={faChevronLeft} /></button>
<button on:click={() => weekOffset++}><Fa icon={faChevronRight} /></button>
<button on:click={saveSelection}>Submit</button>

{year}
{weekOffset}

{selectedDates.length}
{#key weekOffset}
	{#key monday}
		<div
			class="grid calendar overflow-auto text-xs"
			style={`grid-template-columns: repeat(${x + 1}, 1fr); grid-template-rows: repeat(${
				y + 1
			}, 1fr);`}
			id="weekView"
		>
			<div />
			<div>Monday {monday.getDate()}</div>
			<div>Tuesday {dateOffset(1)}</div>
			<div>Wednesday {dateOffset(2)}</div>
			<div>Thursday {dateOffset(3)}</div>
			<div>Friday {dateOffset(4)}</div>
			<div>Saturday {dateOffset(5)}</div>
			<div>Sunday {dateOffset(6)}</div>
			{#each gridDates as row, j}
				<div class="bg-primary text-white items-center flex justify-center">{j}</div>
				{#each row as date, i}
					<button class="border h-24 w-24" on:click={() => toggleDate(date)}>
						{#if selectedDates.find((_date) => _date?.getTime() === date?.getTime())}
							<div class="bg-green-600 h-full w-full flex items-center justify-center">
								<Fa icon={faCheck} color="white" />
							</div>
						{:else}
							<slot {i} {j} />
						{/if}
					</button>
				{/each}
			{/each}
		</div>
	{/key}
{/key}

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

<script lang="ts">
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import type { scheduledEvent } from '$lib/Schedule/interface';
	import { setDateToMidnight } from '$lib/Generic/Dates';
	import { elipsis } from '$lib/Generic/GenericFunctions';

	export let Class = '',
		x: number,
		y: number,
		advancedTimeSettingsDates: Date[] = [],
		//A fix due to class struggle
		selectedDatePosition = '0-0',
		showCreateScheduleEvent = false,
		selectedDate = new Date(),
		month,
		year,
		events: scheduledEvent[] = [];

	const currentDate = new Date();

	const getDate = (year: number, month: number, x: number, y: number) => {
		return new Date(year, month, getDay(x, y));
	};

	const firstDayInMonthWeekday = () => {
		return new Date(year, month, 0).getDay();
	};

	const getDay = (x: number, y: number) => {
		return -firstDayInMonthWeekday() + x + 7 * (y - 1);
	};

	const isToday = () => {
		return (
			getDay(x, y) === currentDate.getDate() &&
			month === currentDate.getMonth() &&
			year === currentDate.getFullYear()
		);
	};

	onMount(() => {
		const today = new Date();
		let tomorow = new Date();
		tomorow.setDate(today.getDate() + 1);
		advancedTimeSettingsDates = [today, tomorow];
	});
</script>

<!-- The line for poll creation -->
<button
	on:dblclick={() => (showCreateScheduleEvent = true)}
	class={`${Class} dark:text-darkmodeText dark:hover:brightness-125 dark:bg-darkobject relative calendar-day border-l border-t border-gray-400 select-none cursor-pointer text-gray-600 transition-all duration-20`}
	id={`${x}-${y}`}
	on:click={() => {
		//Whenever user clicks on a date, ensure that it looks selected.
		document.getElementById(selectedDatePosition)?.classList.remove('selected');
		document.getElementById(`${x}-${y}`)?.classList.add('selected');
		selectedDatePosition = `${x}-${y}`;
		selectedDate = new Date(year, month, getDay(x, y));
	}}
>
	<div class="w-full flex flex-col items-center">
		<div
			class={`px-1 rounded-full flex justify-center 
			${isToday() ? 'bg-secondary text-white w-[25%]' : ''}`}
		>
			<div>{new Date(year, month, getDay(x, y)).getDate()}</div>
		</div>
		{#each events as event}
			{#if new Date(event.start_date) <= getDate(year, month, x, y) && new Date(event.end_date) >= getDate(year, month, x, y)}
				<div class="break-all bg-secondary w-full text-white text-sm mb-1 text-center">
					{elipsis(event.title, 15)}
				</div>
			{/if}
		{/each}
	</div>
</button>

<style>
	.selected {
		box-shadow: inset 0 0 10px 1px rgba(0, 0, 0, 0.4) !important;
	}

	.today {
		box-shadow: inset 0 0 4px 1px var(--secondary) !important;
		background-color: var(--secondary);
	}

	.today.selected {
		box-shadow: inset 0 0 10px 1px var(--secondary) !important;
	}

	.calendar-day {
		display: flex;
		justify-content: center;
		min-height: 80px; /* Add minimum height to make the days consistent */
	}

	.calendar-day:hover {
		box-shadow: inset 0 0 2px 2px rgba(0, 0, 0, 0.1);
	}
</style>

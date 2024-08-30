<script lang="ts">
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import type { scheduledEvent } from '$lib/Schedule/interface';
	import { setDateToMidnight } from '$lib/Generic/Dates';

	export let Class = '',
		type: 'user' | 'group' | 'pollcreation',
		x: number,
		y: number,
		advancedTimeSettingsDates: Date[] = [],
		//A fix due to class struggle
		selectedDatePosition = '0-0',
		showCreateScheduleEvent = false;

	const currentDate = new Date();

	let month = currentDate.getMonth(),
		year = currentDate.getFullYear(),
		selectedDate = new Date(),
		events: scheduledEvent[] = [];

	onMount(() => {
		const today = new Date();
		let tomorow = new Date();
		tomorow.setDate(today.getDate() + 1);
		advancedTimeSettingsDates = [today, tomorow];
	});

	const getDate = (year: number, month: number, x: number, y: number) => {
		return new Date(year, month, getDay());
	};

	const firstDayInMonthWeekday = () => {
		return new Date(year, month, 0).getDay();
	};

	const isEventOnDate = (date: Date) => {
		let eventsOnDate = events;
		eventsOnDate = eventsOnDate.filter((event) => {
			return (
				date >= setDateToMidnight(new Date(event.start_date)) && date <= new Date(event.end_date)
			);
		});

		return eventsOnDate.length > 0;
	};

	const getDay = () => {
		return -firstDayInMonthWeekday() + x + 7 * (y - 1);
	};
</script>

<!-- The line for poll creation -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	on:dblclick={() => {
		if (type === 'user') showCreateScheduleEvent = true;
	}}
	class={`dark:text-darkmodeText dark:hover:brightness-125 dark:bg-darkobject relative calendar-day border-l border-t border-gray-400 select-none cursor-pointer text-gray-600 transition-all duration-20`}
	id={`${x}-${y}`}
	class:today={getDay() === currentDate.getDate() &&
		month === currentDate.getMonth() &&
		year === currentDate.getFullYear()}
	on:click={() => {
		document.getElementById(selectedDatePosition)?.classList.remove('selected');
		document.getElementById(`${x}-${y}`)?.classList.add('selected');
		selectedDatePosition = `${x}-${y}`;
		selectedDate = new Date(year, month, getDay());
	}}
	on:keydown
>
	<div class="w-full">
		<div class="text-center">
			{new Date(year, month, getDay()).getDate()}
		</div>

		{#if type === 'pollcreation'}
			<swappable
				id={`${x}-${y}-draggable`}
				class="py-5 px-1"
				class:!bg-blue-600={advancedTimeSettingsDates
					?.find((date) => date?.getDate() === getDay())
					?.getDate()}
			/>
		{/if}

		{#each events as event}
			{#if new Date(event.start_date) <= getDate(year, month, x + 1, y) && new Date(event.end_date) >= getDate(year, month, x, y)}
				<div class="text-center">{event.title}</div>
			{/if}
		{/each}
		<!-- 
			{#if isEventOnDate(new Date(year, month, -firstDayInMonthWeekday() + x + 7 * (y - 1))) && events.length > 0}
            <Fa class="m-auto" icon={faCalendarAlt} />
			{/if} -->
	</div>
</div>

<style>
	.selected {
		box-shadow: inset 0 0 2px 3px rgba(0, 0, 0, 0.4) !important;
	}

	.today {
		box-shadow: inset 0 0 0 2px var(--primary-color) !important;
	}

	.calendar-day {
		display: flex;
		justify-content: center;
	}

	.calendar-day:hover {
		box-shadow: inset 0 0 2px 2px rgba(0, 0, 0, 0.1);
	}
</style>

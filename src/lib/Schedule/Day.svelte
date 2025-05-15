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
		selectedDatePosition = '0-0',
		showCreateScheduleEvent = false,
		showEvent = false,
		selectedDate = new Date(),
		month,
		year,
		events: scheduledEvent[] = [],
		selectedEvent: scheduledEvent = {
			start_date: '',
			end_date: '',
			title: '',
			description: '',
			meeting_link: '',
			event_id: 0,
			schedule_origin_name: 'group',
			created_by: 0
		};

	const currentDate = new Date();

	const getDate = (year: number, month: number, x: number, y: number) => {
		return new Date(year, month, getDay(x, y) - 1);
	};

	const firstDayInMonthWeekday = () => {
		return new Date(year, month, 0).getDay();
	};

	const getDay = (x: number, y: number) => {
		return firstDayInMonthWeekday() + x + 7 * (y - 2);
	};

	const isToday = () => {
		return (
			getDay(x, y) === currentDate.getDate() &&
			month === currentDate.getMonth() &&
			year === currentDate.getFullYear()
		);
	};

	const getEventsAtDate = (date: Date) => {
		return events
			?.filter((event) => {
				let startDate = new Date(event.start_date);
				startDate.setHours(0);
				startDate.setMinutes(0);
				startDate.setSeconds(0);
				if (startDate <= date && new Date(event.end_date) >= date)
					console.log(event, date, new Date().getTimezoneOffset());
				return startDate <= date && new Date(event.end_date) >= date;
			})
			.sort((a, b) => {
				const dateA = new Date(a.start_date).getTime();
				const dateB = new Date(b.start_date).getTime();
				return dateA === dateB ? a.event_id - b.event_id : dateA - dateB;
			});
	};

	onMount(() => {
		const today = new Date();
		let tomorrow = new Date();
		tomorrow.setDate(today.getDate());
		advancedTimeSettingsDates = [today, tomorrow];
	});
</script>

<!-- The line for poll creation -->
<button
	on:dblclick={() => {
		console.log("x, y", x, y)
		const clickedDate = new Date(year, month, getDay(x, y));
		clickedDate.setHours(0, 0, 0, 0); // Set to midnight for consistency
		const dateStr = formatDateForLocalInput(clickedDate);
		selectedEvent = {
			start_date: dateStr,
			end_date: dateStr,
			title: '',
			description: '',
			meeting_link: '',
			event_id: 0,
			schedule_origin_name: 'group',
			created_by: 0,
			work_group: undefined
		};
		selectedDate = clickedDate;
		showCreateScheduleEvent = true;
	}}
	class={`${Class} dark:text-darkmodeText dark:hover:brightness-125 dark:bg-darkobject relative calendar-day border-l border-t border-gray-400 select-none cursor-pointer text-gray-600 transition-all duration-20`}
	id={`${x}-${y}`}
	on:click={() => {
		// Whenever user clicks on a date, ensure that it looks selected.
		document.getElementById(selectedDatePosition)?.classList.remove('selected');
		document.getElementById(`${x}-${y}`)?.classList.add('selected');
		selectedDatePosition = `${x}-${y}`;
		selectedDate = new Date(year, month, getDay(x, y));
	}}
>
	<div class="w-full flex flex-col items-center">
		{#key events || month || year || window.innerHeight}
			<div
				class={`px-1 rounded-full flex justify-center
			${isToday() ? 'bg-secondary text-white w-[25%]' : ''}`}
			>
				<div>{new Date(year, month, getDay(x, y)).getDate()}</div>
			</div>
			{#if getEventsAtDate(getDate(year, month, x, y))?.length > 0}
				{#each getEventsAtDate(getDate(year, month, x, y)) as event, i}
					{#if (1000 * i) / window.innerHeight < 3}
						<button
							on:click={() => {
								const formattedStart = new Date(event.start_date).toISOString().slice(0, 16);
								const formattedEnd = new Date(event.end_date).toISOString().slice(0, 16);
								selectedEvent = {
									...event,
									start_date: formattedStart,
									end_date: formattedEnd,
									description: event.description || '',
									meeting_link: event.meeting_link || ''
								};
								showEvent = true;
							}}
							class="break-all bg-secondary w-full text-white text-sm mb-1 text-center"
						>
							{elipsis(event.title, 15)}
						</button>
					{/if}
				{/each}
			{/if}
		{/key}
	</div>
</button>

<!-- Helper function to format date for local datetime-local input -->
<script context="module" lang="ts">
	function formatDateForLocalInput(date: Date): string {
		const pad = (num: number) => num.toString().padStart(2, '0');
		const year = date.getFullYear();
		const month = pad(date.getMonth() + 1);
		const day = pad(date.getDate());
		const hours = pad(date.getHours() || 0);
		const minutes = pad(date.getMinutes() || 1);
		return `${year}-${month}-${day}T${hours}:${minutes}`;
	}
</script>

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
<script lang="ts">
	import { onMount } from 'svelte';
	import { faChevronLeft } from '@fortawesome/free-solid-svg-icons/faChevronLeft';
	import { faChevronRight } from '@fortawesome/free-solid-svg-icons/faChevronRight';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { scheduledEvent } from '$lib/Schedule/interface';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import Modal from '$lib/Generic/Modal.svelte';
	import { DateInput } from 'date-picker-svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { page } from '$app/stores';
	import { addDateOffset, setDateToMidnight } from '$lib/Generic/Dates';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import TextArea from '$lib/Generic/TextArea.svelte';

	export let Class = '',
		type: 'user' | 'group' | 'pollcreation',
		x: number,
		y: number;

	const months = [
		'Jan',
		'Feb',
		'Mar',
		'Apr',
		'May',
		'Jun',
		'Jul',
		'Aug',
		'Sep',
		'Oct',
		'Nov',
		'Dec'
	];

	const currentDate = new Date(),
		groupId = $page.params.groupId;

	let month = currentDate.getMonth(),
		year = currentDate.getFullYear(),
		selectedDate = new Date(),
		events: scheduledEvent[] = [],
		loading = false,
		showCreateScheduleEvent = false,
		showEditScheduleEvent = false,
		showEvent = false,
		show = false,
		status: StatusMessageInfo | undefined = undefined,
		//A fix due to class struggle
		selectedDatePosition = '0-0',
		//Variables for creating new scheduled events
		start_date: Date | null,
		end_date: Date | null,
		title: string,
		description: string,
		event_id: number | undefined,
		deleteSelection = () => {};


	const getDate = (year: number, month: number, x: number, y: number) => {
		return new Date(year, month, -firstDayInMonthWeekday() + x + 7 * (y - 1));
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
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	on:dblclick={() => {
		if (type === 'user') showCreateScheduleEvent = true;
	}}
	class={`dark:text-darkmodeText dark:hover:brightness-125 dark:bg-darkobject relative calendar-day border-l border-t border-gray-400 select-none cursor-pointer text-gray-600 transition-all duration-20`}
	id={`${x}-${y}`}
	class:today={-firstDayInMonthWeekday() + x + 7 * (y - 1) === currentDate.getDate() &&
		month === currentDate.getMonth() &&
		year === currentDate.getFullYear()}
	on:click={() => {
		document.getElementById(selectedDatePosition)?.classList.remove('selected');
		document.getElementById(`${x}-${y}`)?.classList.add('selected');
		selectedDatePosition = `${x}-${y}`;
		selectedDate = new Date(year, month, -firstDayInMonthWeekday() + x + 7 * (y - 1));
	}}
	on:keydown
>
	<div class="w-full">
		<div class="text-center">
			{new Date(year, month, -firstDayInMonthWeekday() + x + 7 * (y - 1)).getDate()}
		</div>

		<!-- The line for poll creation -->
		{#if type === 'pollcreation'}
			<div id={`${x}-${y}-draggable`} class="p-1 bg-gray-600 w-1 h-16" />
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

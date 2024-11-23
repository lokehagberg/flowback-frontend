<!-- TODO: Split up this file into two files, one about functionality and the other about visuals -->

<script lang="ts">
	import { onMount } from 'svelte';
	import { faChevronLeft } from '@fortawesome/free-solid-svg-icons/faChevronLeft';
	import { faChevronRight } from '@fortawesome/free-solid-svg-icons/faChevronRight';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { scheduledEvent } from '$lib/Schedule/interface';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import Modal from '$lib/Generic/Modal.svelte';
	import { DateInput } from 'date-picker-svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { page } from '$app/stores';
	import { addDateOffset, setDateToMidnight } from '$lib/Generic/Dates';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Day from './Day.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';

	export let Class = '',
		type: 'user' | 'group';

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
		//A fix due to class struggle
		selectedDatePosition = '0-0',
		//Variables for creating new scheduled events
		start_date: Date | null,
		end_date: Date | null,
		title: string,
		description: string,
		workGroup: { name: string; id: number } | null = null,
		event_id: number | undefined,
		deleteSelection = () => {},
		advancedTimeSettingsDates: Date[] = [],
		notActivated = true,
		workGroups: WorkGroup[] = [],
		poppup: poppup;

	const updateMonth = () => {
		if (month === 12) {
			year += 1;
			month = 0;
		}
		if (month === -1) {
			year -= 1;
			month = 11;
		}
	};

	const setUpScheduledPolls = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			groupId ? `group/${groupId}/schedule?limit=1000` : 'user/schedule?limit=1000'
		);
		events = json.results;
	};

	const scheduleEventCreate = async () => {
		let API = '';
		let payload: any = {
			start_date,
			end_date,
			title,
			description
		};

		if (type === 'user') {
			API += `user/schedule/create`;
		} else if (type === 'group') {
			API += `group/${$page.params.groupId}/schedule/create`;
			if (workGroup) payload['work_group_id'] = workGroup;
		}

		loading = true;
		const { res, json } = await fetchRequest('POST', API, payload);

		loading = false;

		if (!res.ok) {
			poppup = { message: 'Failed to create event', success: false };
			return;
		}

		poppup = { message: 'Successfully created event', success: true };
		showCreateScheduleEvent = false;
		events.push({
			created_by: Number(localStorage.getItem('userId')),
			description: '',
			end_date: end_date?.toString() || '',
			start_date: start_date?.toString() || '',
			event_id: json.id,
			score: 0,
			title,
			schedule_origin_name: 'user'
		});
		events = events;

		start_date = selectedDate;
		end_date = null;
		title = '';
		description = '';
		event_id = undefined;
	};

	const scheduleEventEdit = async (e: any) => {
		loading = true;
		const { res, json } = await fetchRequest('POST', `user/schedule/update`, {
			event_id,
			start_date,
			end_date,
			title,
			description
		});

		loading = false;

		if (!res.ok) {
			poppup = { message: 'Failed to edit event', success: false };
			return;
		}

		showEditScheduleEvent = false;
		events = events.map((event) => {
			if (event.event_id === event_id)
				return {
					created_by: Number(localStorage.getItem('userId')),
					description,
					end_date: end_date?.toString() || '',
					start_date: start_date?.toString() || '',
					event_id: json,
					score: 0,
					title,
					schedule_origin_name: 'user'
				};
			else return event;
		});

		start_date = selectedDate;
		end_date = null;
		title = '';
		description = '';
		event_id = undefined;
	};

	const scheduleEventDelete = async () => {
		const { res, json } = await fetchRequest('POST', `user/schedule/delete`, {
			event_id
		});

		loading = false;

		if (!res.ok) {
			poppup = { message: 'Failed to delete event', success: false };
			return;
		}

		poppup = { message: 'Event deleted', success: true };
		events = events.filter((event) => event.event_id !== event_id);
		events = events;

		showEditScheduleEvent = false;

		start_date = selectedDate;
		end_date = null;
		title = '';
		description = '';
		event_id = undefined;
	};

	const handleShowEvent = (event: scheduledEvent) => {
		start_date = new Date(event.start_date);
		end_date = new Date(event.end_date);
		title = event.title;
		description = event.description;
		event_id = event.event_id;
		if (event.work_group) workGroup = event.work_group;
		showEvent = true;
	};

	const getWorkGroups = async () => {
		const { res, json } = await fetchRequest('GET', `group/${$page.params.groupId}/list`);

		if (!res.ok) return;
		workGroups = json.results;
	};

	onMount(async () => {
		//Prevents "document not found" error
		deleteSelection = () => {
			document.getElementById(selectedDatePosition)?.classList.remove('selected');
		};

		setUpScheduledPolls();
		getWorkGroups();
	});

	$: month && year && deleteSelection();

	$: month && updateMonth();

	$: if (showCreateScheduleEvent && notActivated) {
		notActivated = false;
		start_date = selectedDate;
		end_date = addDateOffset(selectedDate, 1, 'hour');
	}

	$: if (!showCreateScheduleEvent) notActivated = true;
</script>

<div class={`flex bg-white dark:bg-darkobject dark:text-darkmodeText ${Class}`}>
	<div class="border-right-2 border-black p-4 pl-6 pr-6 w-1/4">
		{$_('Scheduled events for')}
		{selectedDate.getDate()}/{selectedDate.getMonth() + 1}
		{selectedDate.getFullYear()}

		<div class="pt-3 pb-3">
			<button on:click={() => (showCreateScheduleEvent = true)}>
				<Fa
					class="ml-auto mr-auto hover:bg-gray-200 dark:hover:bg-slate-700 transition p-3 cursor-pointer rounded"
					size="3x"
					icon={faPlus}
				/>
			</button>
			{#each events.filter((poll) => setDateToMidnight(new Date(poll.start_date)) <= selectedDate && new Date(poll.end_date) >= selectedDate) as event}
				<div class="mt-2">
					<a
						class="hover:underline cursor-pointer text-xs text-center color-black dark:text-darkmodeText text-black flex justify-between items-center gap-3"
						class:hover:bg-gray-300={event.poll}
						href={event.poll ? `groups/${event.group_id}/polls/${event.poll}` : location.href}
						on:click={() => {
							handleShowEvent(event);
						}}
					>
						<span>{event.title}</span>
						<span
							>{(() => {
								const startDate = new Date(event.start_date);
								const endDate = new Date(event.end_date);

								if (selectedDate.getDate() === startDate.getDate())
									return `Start: ${
										startDate.getHours() > 9 ? startDate.getHours() : '0' + startDate.getHours()
									}:${
										startDate.getMinutes() > 9
											? startDate.getMinutes()
											: '0' + startDate.getMinutes()
									}`;
								else if (selectedDate.getDate() === endDate.getDate())
									return `Ends: ${
										endDate.getHours() > 9 ? endDate.getHours() : '0' + endDate.getHours()
									}:${
										endDate.getMinutes() > 9 ? endDate.getMinutes() : '0' + endDate.getMinutes()
									}`;
								else return 'whole day';
							})()}</span
						>
					</a>
				</div>
			{/each}
		</div>
	</div>

	<div class="w-full">
		<div class="flex">
			<div class="flex items-center select-none">
				<button
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => (year -= 1)}
				>
					<Fa icon={faChevronLeft} size="1.5x" />
				</button>
				<div class="text-xl text-center w-16">{year}</div>

				<button
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => (year += 1)}
				>
					<Fa icon={faChevronRight} size="1.5x" />
				</button>
			</div>

			<div class="flex items-center ml-6 select-none">
				<button
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => (month -= 1)}
				>
					<Fa icon={faChevronLeft} size="1.5x" />
				</button>
				<div class="w-10 text-center">{$_(months[month])}</div>

				<button
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => (month += 1)}
				>
					<Fa icon={faChevronRight} size="1.5x" />
				</button>
			</div>
		</div>
		<div id="calendar" class="calendar w-full">
			{#each [1, 2, 3, 4, 5, 6] as y}
				{#each [1, 2, 3, 4, 5, 6, 7] as x}
					<Day
						bind:showCreateScheduleEvent
						bind:selectedDatePosition
						bind:selectedDate
						bind:year
						bind:month
						bind:advancedTimeSettingsDates
						{x}
						{y}
					/>
				{/each}
			{/each}
		</div>
	</div>
</div>

<!-- Allows user to see event -->
<Modal bind:open={showEvent}>
	<div slot="header">{title}</div>
	<div slot="body">
		<div class="flex flex-col">
			<span>{$_('Start date')}: {formatDate(start_date?.toString())}</span>
			<span>{$_('End date')}: {formatDate(end_date?.toString())}</span>
			<span> {description} </span>
			{#if workGroup}
				{$_('Work Group')}:<span>{workGroup?.name}</span>
			{/if}
		</div>
	</div>
	<div slot="footer">
		<Button
			action={() => {
				showEditScheduleEvent = true;
				showEvent = false;
			}}>{$_('Edit Event')}</Button
		>
	</div>
</Modal>

<!-- Modal for creating one's own/group scheduled event -->
<Modal bind:open={showCreateScheduleEvent}>
	<div slot="header">{$_('Create Event')}</div>
	<div slot="body">
		<Loader bind:loading>
			<form on:submit|preventDefault={scheduleEventCreate}>
				<TextInput placeholder="Event name" label="Title" bind:value={title} />
				<TextArea label="Description" bind:value={description} />
				{#if type === 'group'}
					{$_('Work Group')}
					<Select
						bind:value={workGroup}
						labels={workGroups.map((group) => group.name)}
						values={workGroups.map((group) => group.id)}
					/>
				{/if}
				<input bind:value={start_date} type="datetime-local" />
				<input bind:value={end_date} type="datetime-local" />
				<Button type="submit">{$_('Submit')}</Button>
			</form>
		</Loader>
	</div>
	<div slot="footer" />
</Modal>

<!-- Opens a window which allows users to edit a schedule (TODO: refactor so there's just one combined modal for edit and create) -->
<Modal bind:open={showEditScheduleEvent}>
	<div slot="header">{$_('Edit Event')}</div>
	<div slot="body">
		<Loader bind:loading>
			<form on:submit|preventDefault={scheduleEventEdit}>
				<DateInput bind:value={start_date} format="yyyy-MM-dd HH:mm" />
				<DateInput
					bind:value={end_date}
					format="yyyy-MM-dd HH:mm"
					min={start_date ? addDateOffset(start_date, 1, 'hour') : new Date()}
				/>
				<TextInput label="Event title" bind:value={title} />
				<TextArea label="Event description" bind:value={description} />
				<Button type="submit">{$_('Submit')}</Button>
				<Button buttonStyle="warning" action={scheduleEventDelete}>{$_('Delete')}</Button>
			</form>
		</Loader>
	</div>
</Modal>

<Poppup bind:poppup />

<style>
	.calendar {
		display: grid;
		grid-template-columns: repeat(7, 1fr);
		grid-template-rows: repeat(6, 1fr);
		/* 100vh to stretch the calendar to the bottom, then we subtract 2 rem from the padding
    on the header, 40px from the height of each symbol/the logo on the header, and 
    28 px for the controlls on the calendar. This scuffed solution might need to be improved */
		height: calc(100vh - 2rem - 40px - 28px);
	}
</style>

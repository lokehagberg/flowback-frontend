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
	// import { DateInput } from 'date-picker-svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { page } from '$app/stores';
	import { addDateOffset, setDateToMidnight } from '$lib/Generic/Dates';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Day from './Day.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import Event from './Event.svelte';

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
		meeting_link: string,
		description: string,
		workGroup: { name: string; id: number } | null = null,
		event_id: number | undefined,
		deleteSelection = () => {},
		advancedTimeSettingsDates: Date[] = [],
		notActivated = true,
		workGroups: WorkGroup[] = [],
		workGroupFilter: number[] = [],
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
		let _api = '';

		if (groupId) {
			_api = `group/${groupId}/schedule?limit=1000&`;

			workGroupFilter.forEach((groupId) => {
				_api += `work_group_ids=${groupId}&`;
			});
		} else {
			_api = `user/schedule?limit=1000`;
		}

		console.log('hei', _api);

		const { json, res } = await fetchRequest('GET', _api);
		events = json.results;
	};

	const scheduleEventCreate = async () => {
		let API = '';
		let payload: any = {
			start_date,
			end_date,
			title,
			description,
			meeting_link
		};

		if (description === '') delete payload.description;

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
			meeting_link: '',
			schedule_origin_name: 'user'
		});
		events = events;

		start_date = selectedDate;
		end_date = null;
		title = '';
		description = '';
		meeting_link = '';
		event_id = undefined;
	};

	const scheduleEventEdit = async () => {
		loading = true;
		const { res, json } = await fetchRequest('POST', `user/schedule/update`, {
			event_id,
			start_date,
			end_date,
			title,
			description,
			meeting_link
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
					event_id: json.id,
					score: 0,
					title,
					schedule_origin_name: 'user',
					meeting_link
				};
			else return event;
		});

		start_date = selectedDate;
		end_date = null;
		title = '';
		description = '';
		meeting_link = '';
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

	const onFilterWorkGroup = (workGroup: WorkGroup) => {
		//Once backend is fixed, use the commented out version

		// if (workGroupFilter.find((groupId) => groupId === workGroup.id))
		// 	workGroupFilter = workGroupFilter.filter((groupId) => groupId !== workGroup.id);
		// else workGroupFilter.push(workGroup.id);

		workGroupFilter = [workGroup.id];

		workGroupFilter = workGroupFilter;

		setUpScheduledPolls();
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
		if (selectedDate) end_date = new Date(selectedDate.getTime() + 60 * 60 * 1000);
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
						<span class="break-all">{event.title}</span>
						<span
							>{(() => {
								const startDate = new Date(event.start_date);
								const endDate = new Date(event.end_date);

								if (selectedDate.getDate() === startDate.getDate())
									return `${$_('Start:')} ${
										startDate.getHours() > 9 ? startDate.getHours() : '0' + startDate.getHours()
									}:${
										startDate.getMinutes() > 9
											? startDate.getMinutes()
											: '0' + startDate.getMinutes()
									}`;
								else if (selectedDate.getDate() === endDate.getDate())
									return `${$_('Ends:')} ${
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

		<div class="flex flex-col">
			{#each workGroups as group}
				<Button
					buttonStyle={workGroupFilter.find((_group) => _group === group.id)
						? 'primary'
						: 'secondary'}
					action={() => onFilterWorkGroup(group)}
					Class="mt-2 break-all"
				>
					{group.name}
				</Button>
			{/each}
		</div>
	</div>

	<div class="w-full">
		<div class="flex">
			<div class="flex items-center select-none">
				<button
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => year--}
				>
					<Fa icon={faChevronLeft} size="1.5x" />
				</button>
				<div class="text-xl text-center w-16">{year}</div>

				<button
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => year++}
				>
					<Fa icon={faChevronRight} size="1.5x" />
				</button>
			</div>

			<div class="flex items-center ml-6 select-none">
				<button
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => month--}
				>
					<Fa icon={faChevronLeft} size="1.5x" />
				</button>
				<div class="w-10 text-center">{$_(months[month])}</div>

				<button
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => month++}
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
						bind:events
						{x}
						{y}
					/>
				{/each}
			{/each}
		</div>
	</div>
</div>

<Event
	bind:showEvent
	bind:showCreateScheduleEvent
	bind:showEditScheduleEvent
	bind:title
	bind:description
	bind:start_date
	bind:end_date
	bind:meeting_link
	bind:workGroup
	bind:workGroups
	bind:type
	bind:loading
	{scheduleEventCreate}
	{scheduleEventEdit}
	{scheduleEventDelete}
/>

<Poppup bind:poppup />

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

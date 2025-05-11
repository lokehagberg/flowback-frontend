<script lang="ts">
	import { onMount } from 'svelte';
	import { faChevronLeft } from '@fortawesome/free-solid-svg-icons/faChevronLeft';
	import { faChevronRight } from '@fortawesome/free-solid-svg-icons/faChevronRight';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { scheduledEvent } from '$lib/Schedule/interface';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import Button from '$lib/Generic/Button.svelte';
	import { page } from '$app/stores';
	import { addDateOffset, setDateToMidnight } from '$lib/Generic/Dates';
	import Day from './Day.svelte';
	import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import Event from './Event.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import MultipleChoices from '$lib/Generic/MultipleChoices.svelte';

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
		groupId = $page.params.groupId || '1';

	let month = currentDate.getMonth(),
		year = currentDate.getFullYear(),
		selectedDate = new Date(),
		events: scheduledEvent[] = [],
		loading = false,
		showCreateScheduleEvent = false,
		showEditScheduleEvent = false,
		showEvent = false,
		// A fix due to class struggle
		selectedDatePosition = '0-0',
		selectedEvent: scheduledEvent = {
			title: '',
			description: '',
			start_date: '',
			end_date: '',
			meeting_link: '',
			event_id: 0,
			schedule_origin_name: type,
			created_by: 0,
			work_group: undefined
		},
		deleteSelection = () => {},
		advancedTimeSettingsDates: Date[] = [],
		notActivated = true,
		workGroups: WorkGroup[] = [],
		workGroupFilter: number[] = [],
		poppup: poppup;

	const resetSelectedEvent = () => {
		selectedEvent = {
			title: '',
			description: '',
			start_date: '',
			end_date: '',
			meeting_link: '',
			event_id: 0,
			schedule_origin_name: type,
			created_by: 0,
			work_group: undefined
		};
	};

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

		if (type === 'group') {
			_api = `group/${groupId}/schedule?limit=1000&`;

			if (workGroupFilter.length > 0) {
				_api += 'work_group_ids=';
				workGroupFilter.forEach((groupId) => {
					_api += `${groupId},`;
				});
			}
		} else {
			_api = `user/schedule?limit=1000`;
		}

		const { json, res } = await fetchRequest('GET', _api);
		events = json.results.sort((a: scheduledEvent, b: scheduledEvent) => {
			// Sort by start_date, then event_id for stable ordering
			const dateA = new Date(a.start_date).getTime();
			const dateB = new Date(b.start_date).getTime();
			return dateA === dateB ? a.event_id - b.event_id : dateA - dateB;
		});
		console.log('Fetched events:', events);
	};

	const scheduleEventCreate = async (newEvent: scheduledEvent) => {
		loading = true;

		let API = '';
		let payload: any = {
			title: newEvent.title,
			start_date: newEvent.start_date,
			end_date: newEvent.end_date
		};

		if (newEvent.description) payload.description = newEvent.description;
		if (newEvent.meeting_link) payload.meeting_link = newEvent.meeting_link;
		if (type === 'group' && newEvent.work_group) {
			payload.work_group = newEvent.work_group;
		}

		if (type === 'user') {
			API += `user/schedule/create`;
		} else if (type === 'group') {
			API += `group/${$page.params.groupId || 1}/schedule/create`;
		}

		const { res, json } = await fetchRequest('POST', API, payload);

		loading = false;

		if (!res.ok) {
			poppup = { message: 'Failed to create event', success: false };
			return;
		}
		// console.log(json);
		const createdEvent = { ...selectedEvent, event_id: json.id };
		events.push(createdEvent);
		events = events;
		console.log(events);
		poppup = { message: 'Successfully created event', success: true };
		showCreateScheduleEvent = false;

		// Create new event object with all required properties
		const createdEvent: scheduledEvent = {
			...newEvent,
			event_id: json.event_id,
			schedule_origin_name: type,
			created_by: newEvent.created_by || 0,
			work_group: newEvent.work_group || undefined
		};

		// Update events array reactively
		events = [...events, createdEvent].sort((a, b) => {
			const dateA = new Date(a.start_date).getTime();
			const dateB = new Date(b.start_date).getTime();
			return dateA === dateB ? a.event_id - b.event_id : dateA - dateB;
		});

		// Refresh calendar data to ensure consistency
		await setUpScheduledPolls();

		resetSelectedEvent();
	};

	const scheduleEventUpdate = async (updatedEvent: scheduledEvent) => {
		loading = true;

		let payload: any = {
			event_id: updatedEvent.event_id,
			title: updatedEvent.title,
			start_date: updatedEvent.start_date,
			end_date: updatedEvent.end_date
		};

		if (updatedEvent.description) payload.description = updatedEvent.description;
		if (updatedEvent.meeting_link) payload.meeting_link = updatedEvent.meeting_link;
		if (type === 'group' && updatedEvent.work_group) {
			payload.work_group = updatedEvent.work_group;
		}

		const { res, json } = await fetchRequest(
			'POST',
			type === 'group' ? `group/${groupId}/schedule/update` : `user/schedule/update`,
			payload
		);

		loading = false;

		if (!res.ok) {
			poppup = { message: 'Failed to edit event', success: false };
			return;
		}

		events = events
			.map((event) => (event.event_id === updatedEvent.event_id ? { ...updatedEvent } : event))
			.sort((a, b) => {
				const dateA = new Date(a.start_date).getTime();
				const dateB = new Date(b.start_date).getTime();
				return dateA === dateB ? a.event_id - b.event_id : dateA - dateB;
			});
		resetSelectedEvent();
		showEditScheduleEvent = false;

		// Refresh calendar data
		await setUpScheduledPolls();
	};

	const scheduleEventDelete = async (eventId: number) => {
		loading = true;

		const { res, json } = await fetchRequest(
			'POST',
			type === 'group' ? `group/${groupId}/schedule/delete` : `user/schedule/delete`,
			{
				event_id: eventId
			}
		);

		loading = false;

		if (!res.ok) {
			poppup = { message: 'Failed to delete event', success: false };
			return;
		}

		poppup = { message: 'Event deleted', success: true };
		events = events.filter((event) => event.event_id !== eventId);
		events = events;
		showEvent = false;
		resetSelectedEvent();

		// Refresh calendar data
		await setUpScheduledPolls();
	};

	const handleShowEvent = (event: scheduledEvent) => {
		const formattedStart = new Date(event.start_date).toISOString().slice(0, 16);
		const formattedEnd = new Date(event.end_date).toISOString().slice(0, 16);
		selectedEvent = {
			...event,
			start_date: formattedStart,
			end_date: formattedEnd,
			description: event.description || '',
			meeting_link: event.meeting_link || '',
			work_group: event.work_group || undefined
		};
		showEvent = true;
	};

	const getWorkGroupList = async () => {
		const { res, json } = await fetchRequest('GET', `group/${groupId}/list`);

		if (!res.ok) return;
		workGroups = json.results.filter((group: WorkGroup) => group.joined === true);
	};

	const onFilterWorkGroup = (workGroup: WorkGroup) => {
		if (workGroupFilter.find((groupId) => groupId === workGroup.id))
			workGroupFilter = workGroupFilter.filter((groupId) => groupId !== workGroup.id);
		else workGroupFilter.push(workGroup.id);

		workGroupFilter = workGroupFilter;
		setUpScheduledPolls();
	};

	// Convert time from UTC to local time
	const formatDateToLocalTime = (date: Date): String => {
		try {
			const offset = date.setTime(date.getTime() - date.getTimezoneOffset() * 60000);
			const localTime = new Date(offset).toISOString();
			return localTime;
		} catch (error) {
			console.error('Error converting date to string:', error);
			return date.toString();
		}
	};

	onMount(async () => {
		deleteSelection = () => {
			document.getElementById(selectedDatePosition)?.classList.remove('selected');
		};

		setUpScheduledPolls();
		getWorkGroupList();
	});

	$: month && year && deleteSelection();

	$: month && updateMonth();

	$: if (showCreateScheduleEvent && notActivated) {
		notActivated = false;
	}

	$: if (!showCreateScheduleEvent) notActivated = true;
</script>

<div class={`flex bg-white dark:bg-darkobject dark:text-darkmodeText ${Class}`}>
	<div class="border-right-2 border-black p-4 pl-6 pr-6 w-1/4">
		{$_('Scheduled events for')}
		{selectedDate.getDate()}/{selectedDate.getMonth() + 1}
		{selectedDate.getFullYear()}

		<div class="pt-3 pb-3">
			<button
				on:click={() => {
					const dateStr = selectedDate.toISOString().slice(0, 16);
					console.log('Sidebar create clicked - selectedDate:', selectedDate, 'Formatted:', dateStr);
					selectedEvent = {
						start_date: dateStr,
						end_date: dateStr,
						title: '',
						description: '',
						meeting_link: '',
						event_id: 0,
						schedule_origin_name: type,
						created_by: 0,
						work_group: undefined
					};
					showCreateScheduleEvent = true;
<<<<<<< HEAD
					selectedEvent.start_date = formatDateToLocalTime(selectedDate).slice(0, 16);
					selectedEvent.end_date = formatDateToLocalTime(selectedDate).slice(0, 16);
=======
>>>>>>> 3862c34c (fixed the Events (at least those with the same start and end dates and times) change place when reloading and just after reloading you get the error “this field can not be null” on description when you try to create a new event)
				}}
			>
				<Fa
					class="ml-auto mr-auto hover:bg-gray-200 dark:hover:bg-slate-700 transition p-3 cursor-pointer rounded"
					size="3x"
					icon={faPlus}
				/>
			</button>
		</div>

		<div class="flex flex-col">
			{#each workGroups as workGroup}
				<div class="flex items-center gap-2">
					<input
						type="checkbox"
						id={workGroup.id.toString()}
						checked={workGroupFilter.includes(workGroup.id)}
						on:change={() => onFilterWorkGroup(workGroup)}
					/>
					<span>{workGroup.name}</span>
				</div>
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
						bind:advancedTimeSettingsDates
						bind:selectedDatePosition
						bind:selectedEvent
						bind:selectedDate
						bind:showEvent
						bind:events
						bind:month
						bind:year
						{x}
						{y}
					/>
				{/each}
			{/each}
		</div>
	</div>
</div>

<Event
	bind:showCreateScheduleEvent
	bind:showEditScheduleEvent
	bind:selectedEvent
	bind:workGroups
	bind:showEvent
	bind:loading
	bind:type
	{scheduleEventCreate}
	scheduleEventEdit={scheduleEventUpdate}
	scheduleEventDelete={scheduleEventDelete}
/>

<Poppup bind:poppup />

<style>
	.calendar {
		display: grid;
		grid-template-columns: repeat(7, 1fr);
		grid-template-rows: repeat(6, 1fr);
		height: calc(100vh - 2rem - 40px - 28px);
	}
</style>
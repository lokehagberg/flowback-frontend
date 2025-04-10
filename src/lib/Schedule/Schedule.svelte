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
		//A fix due to class struggle
		selectedDatePosition = '0-0',
		selectedEvent = {
			title: '',
			description: '',
			start_date: '',
			end_date: '',
			meeting_link: '',
			event_id: 0,
			created_by: 0
		},
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
		events = json.results;
		console.log(events, 'events');
	};

	const scheduleEventCreate = async () => {
		loading = true;

		let API = '';
		let payload: any = selectedEvent;

		if (selectedEvent.meeting_link !== '') payload['meeting_link'] = selectedEvent.meeting_link;
		if (selectedEvent.meeting_link === '' || selectedEvent.meeting_link === undefined)
			delete payload.meeting_link;

		if (selectedEvent.description === '') delete payload.description;

		console.log(type, 'TYp');

		if (type === 'user') {
			API += `user/schedule/create`;
		} else if (type === 'group') {
			API += `group/${$page.params.groupId || 1}/schedule/create`;
		}

		const { res, json } = await fetchRequest('POST', API, payload);

		loading = false;

		if (!res.ok) {
			console.log(res, json);
			poppup = { message: 'Failed to create event', success: false };
			return;
		}

		poppup = { message: 'Successfully created event', success: true };
		showCreateScheduleEvent = false;
		events.push(selectedEvent);
		events = events;

		selectedEvent = {
			start_date: '',
			end_date: '',
			title: '',
			event_id: 0,
			schedule_origin_name: 'group',
			created_by: 0
		};
	};

	const scheduleEventUpdate = async () => {
		// Clone the current event so we keep its values
		const updatedEvent = { ...selectedEvent };

		// Build payload from the cloned object
		let payload: any = { ...updatedEvent };

		if (updatedEvent.meeting_link !== '') payload['meeting_link'] = updatedEvent.meeting_link;

		if (updatedEvent.description === '' || updatedEvent.description === null)
			delete payload.description;
		if (updatedEvent.meeting_link === '' || updatedEvent.meeting_link === null)
			delete payload.meeting_link;

		loading = true;

		const { res, json } = await fetchRequest(
			'POST',
			groupId ? `group/${groupId}/schedule/update` : `user/schedule/update`,
			payload
		);

		loading = false;

		if (!res.ok) {
			poppup = { message: 'Failed to edit event', success: false };
			return;
		}

		// Update the events array using the temporary updatedEvent
		events = events.map((event) =>
			event.event_id === updatedEvent.event_id ? updatedEvent : event
		);

		// Now reset selectedEvent
		selectedEvent = {
			start_date: '',
			end_date: '',
			title: '',
			event_id: 0,
			schedule_origin_name: 'group',
			created_by: 0
		};
	};

	showEditScheduleEvent = false;

	const scheduleEventDelete = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			groupId ? `group/${groupId}/schedule/delete` : `user/schedule/delete`,
			{
				event_id: selectedEvent.event_id
			}
		);

		loading = false;

		if (!res.ok) {
			poppup = { message: 'Failed to delete event', success: false };
			return;
		}

		poppup = { message: 'Event deleted', success: true };
		events = events.filter((event) => event.event_id !== selectedEvent.event_id);
		events = events;

		showEvent = false;
	};

	const handleShowEvent = (event: scheduledEvent) => {
		selectedEvent = event;
		showEvent = true;
	};

	const getWorkGroupList = async () => {
		const { res, json } = await fetchRequest('GET', `group/${groupId}/list`);

		if (!res.ok) return;
		workGroups = json.results.filter((group: WorkGroup) => group.joined === true);
	};

	const onFilterWorkGroup = (workGroup: WorkGroup) => {
		//Once backend is fixed, use the commented out version

		if (workGroupFilter.find((groupId) => groupId === workGroup.id))
			workGroupFilter = workGroupFilter.filter((groupId) => groupId !== workGroup.id);
		else workGroupFilter.push(workGroup.id);

		// workGroupFilter = [workGroup.id];

		workGroupFilter = workGroupFilter;

		setUpScheduledPolls();
	};

	onMount(async () => {
		//Prevents "document not found" error
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

	$: console.log(selectedEvent.title, 'HELLo');
</script>

<div class={`flex bg-white dark:bg-darkobject dark:text-darkmodeText ${Class}`}>
	<div class="border-right-2 border-black p-4 pl-6 pr-6 w-1/4">
		{$_('Scheduled events for')}
		{selectedDate.getDate()}/{selectedDate.getMonth() + 1}
		{selectedDate.getFullYear()}

		<div class="pt-3 pb-3">
			<button
				on:click={() => {
					showCreateScheduleEvent = true;
					selectedEvent.start_date = selectedDate.toISOString().slice(0, 16);
					selectedEvent.end_date = selectedDate.toISOString().slice(0, 16);
				}}
			>
				<Fa
					class="ml-auto mr-auto hover:bg-gray-200 dark:hover:bg-slate-700 transition p-3 cursor-pointer rounded"
					size="3x"
					icon={faPlus}
				/>
			</button>
			<!-- {#each events.filter((poll) => setDateToMidnight(new Date(poll.start_date)) <= selectedDate && new Date(poll.end_date) >= selectedDate) as event}
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
			{/each} -->
		</div>

		<div class="flex flex-col">
			{#each workGroups as workGroup}
				<div class="flex items-center gap-2">
					<input
						type="checkbox"
						id={workGroup.id.toString()}
						value={workGroupFilter.find((_workGroup) => _workGroup === workGroup.id)}
						on:input={() => onFilterWorkGroup(workGroup)}
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

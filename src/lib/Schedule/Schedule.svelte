<!-- TODO: Split up this file into two files, one about functionality and the other about visuals -->

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
	import Day from './Day.svelte';

	export let Class = '',
		type: 'user' | 'group' | 'pollcreation',
		start_date_poll: Date = new Date(),
		area_vote_end_date: Date = new Date(),
		proposal_end_date: Date = new Date(),
		prediction_statement_end_date: Date = new Date(),
		prediction_bet_end_date: Date = new Date(),
		delegate_vote_end_date: Date = new Date(),
		vote_end_date: Date = new Date(),
		end_date_poll: Date = new Date();

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
		deleteSelection = () => {},
		advancedTimeSettingsDates: Date[] = [];

	onMount(async () => {
		//Prevents "document not found" error
		deleteSelection = () => {
			document.getElementById(selectedDatePosition)?.classList.remove('selected');
		};

		setUpScheduledPolls();
		if (type === 'pollcreation') setUpDraggable();
	});

	$: month && year && deleteSelection();
	$: month && updateMonth();

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

	const scheduleEventCreate = async (e: any) => {
		loading = true;
		const { res, json } = await fetchRequest('POST', `user/schedule/create`, {
			start_date,
			end_date,
			title,
			description
		});

		loading = false;

		if (!res.ok) {
			status = statusMessageFormatter(res, json);
			return;
		}

		showCreateScheduleEvent = false;
		show = true;
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
			status = statusMessageFormatter(res, json);
			console.warn(status);
			return;
		}

		showEditScheduleEvent = false;
		show = true;
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
			status = statusMessageFormatter(res, json);
			return;
		}

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
		showEvent = true;
	};

	const setUpDraggable = async () => {
		const { Swappable, Draggable, Sortable, SortAnimation } = await import('@shopify/draggable');
		const draggable = new Swappable(document.getElementById('calendar'), {
			draggable: 'swappable'
		});

		advancedTimeSettingsDates = [
			start_date_poll,
			area_vote_end_date,
			proposal_end_date,
			prediction_statement_end_date,
			prediction_bet_end_date,
			delegate_vote_end_date,
			vote_end_date,
			end_date_poll
		];
	};

	//TODO: refactor the whole schedule and createpoll files to only use an array, which makes it easier to change the number of poll phases
	const updateDraggables = () => {
		// if (advancedTimeSettingsDates.length !== 8) return;
		// start_date_poll = advancedTimeSettingsDates[0];
		// area_vote_end_date = advancedTimeSettingsDates[1];
		// proposal_end_date = advancedTimeSettingsDates[2];
		// prediction_statement_end_date = advancedTimeSettingsDates[3];
		// prediction_bet_end_date = advancedTimeSettingsDates[4];
		// delegate_vote_end_date = advancedTimeSettingsDates[5];
		// vote_end_date = advancedTimeSettingsDates[6];
		// end_date_poll = advancedTimeSettingsDates[7];
	};

	$: if (advancedTimeSettingsDates) updateDraggables();

	$: start_date_poll = advancedTimeSettingsDates[0];

	let notActivated = true;
	$: if (showCreateScheduleEvent && notActivated) {
		notActivated = false;
		start_date = selectedDate;
		end_date = addDateOffset(selectedDate, 1, 'hour');
	}

	$: if (!showCreateScheduleEvent) notActivated = true;

	// $: end_date = start_date ? addDateOffset(start_date, 1, 'hour') : new Date();
</script>

<div class={`flex bg-white dark:bg-darkobject dark:text-darkmodeText ${Class}`}>
	<div class="border-right-2 border-black p-4 pl-6 pr-6 w-1/4">
		{$_('Scheduled events for')}
		{selectedDate.getDate()}/{selectedDate.getMonth() + 1}
		{selectedDate.getFullYear()}

		<div class="pt-3 pb-3">
			<!-- svelte-ignore a11y-no-static-element-interactions -->
			<div on:click={() => (showCreateScheduleEvent = true)} on:keydown>
				{#if type === 'user'}
					<Fa
						class="ml-auto mr-auto hover:bg-gray-200 dark:hover:bg-slate-700 transition p-3 cursor-pointer rounded"
						size="3x"
						icon={faPlus}
					/>
				{/if}
			</div>
			{#each events.filter((poll) => setDateToMidnight(new Date(poll.start_date)) <= selectedDate && new Date(poll.end_date) >= selectedDate) as event}
				<div class="mt-2">
					<a
						class="hover:underline cursor-pointer text-xs text-center color-black dark:text-darkmodeText text-black flex justify-between items-center gap-3"
						class:hover:bg-gray-300={event.poll}
						href={event.poll ? `groups/${event.group_id}/polls/${event.poll}` : location.href}
						on:click={() => {
							if (event.schedule_origin_name === 'user') handleShowEvent(event);
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
				<!-- svelte-ignore a11y-no-static-element-interactions -->
				<div
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => (year -= 1)}
					on:keydown
				>
					<Fa icon={faChevronLeft} size="1.5x" />
				</div>
				<div class="text-xl text-center w-16">{year}</div>
				<!-- svelte-ignore a11y-no-static-element-interactions -->
				<div
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => (year += 1)}
					on:keydown
				>
					<Fa icon={faChevronRight} size="1.5x" />
				</div>
			</div>

			<div class="flex items-center ml-6 select-none">
				<!-- svelte-ignore a11y-no-static-element-interactions -->
				<div
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => (month -= 1)}
					on:keydown
				>
					<Fa icon={faChevronLeft} size="1.5x" />
				</div>
				<div class="w-10 text-center">{$_(months[month])}</div>
				<!-- svelte-ignore a11y-no-static-element-interactions -->
				<div
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => (month += 1)}
					on:keydown
				>
					<Fa icon={faChevronRight} size="1.5x" />
				</div>
			</div>
		</div>
		<div id="calendar" class="calendar w-full">
			{#each [1, 2, 3, 4, 5, 6] as y}
				{#each [1, 2, 3, 4, 5, 6, 7] as x}
					<Day bind:showCreateScheduleEvent bind:selectedDatePosition bind:advancedTimeSettingsDates {type} {x} {y} />
				{/each}
			{/each}
		</div>
	</div>
</div>

<!-- Modal for creating one's own/group scheduled event -->
<Modal
	bind:open={showCreateScheduleEvent}
	onClose={() => {
		if (status !== undefined) status = undefined;
	}}
>
	<div slot="header">{$_('Create Event')}</div>
	<div slot="body">
		<Loader bind:loading>
			<form on:submit|preventDefault={scheduleEventCreate}>
				<DateInput bind:value={start_date} format="yyyy-MM-dd HH:mm" />
				<DateInput
					bind:value={end_date}
					format="yyyy-MM-dd HH:mm"
					min={start_date ? addDateOffset(start_date, 1, 'hour') : new Date()}
				/>
				<TextInput label="Event title" bind:value={title} />
				<TextArea label="Event description" bind:value={description} />
				<StatusMessage bind:status Class="w-full mt-3 mb-3" />
				<Button type="submit">{$_('Submit')}</Button>
			</form>
		</Loader>
	</div>
	<div slot="footer" />
</Modal>

<Modal bind:open={showEvent}>
	<div slot="header">{title}</div>
	<div slot="body">
		<div class="flex flex-col">
			<span>{$_('Start date')}: {formatDate(start_date?.toString())}</span>
			<span>{$_('End date')}: {formatDate(end_date?.toString())}</span>
			<span> {description} </span>
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
				<StatusMessage bind:status Class="w-full mt-3 mb-3" />
				<Button type="submit">{$_('Submit')}</Button>
				<Button buttonStyle="warning" action={scheduleEventDelete}>{$_('Delete')}</Button>
			</form>
		</Loader>
	</div>
</Modal>

<!-- <SuccessPoppup bind:show /> -->

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

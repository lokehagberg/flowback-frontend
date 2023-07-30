<!-- TODO: Split up this file into two files, one about functionality and the other about visuals -->

<script lang="ts">
	import { onMount } from 'svelte';
	import { faChevronLeft } from '@fortawesome/free-solid-svg-icons/faChevronLeft';
	import { faChevronRight } from '@fortawesome/free-solid-svg-icons/faChevronRight';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { scheduledEvent } from '$lib/Schedule/interface';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import Modal from '$lib/Generic/Modal.svelte';
	import { DateInput } from 'date-picker-svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { page } from '$app/stores';
	import { addDateOffset } from '$lib/Generic/Dates';

	export let Class = '';

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
		show = false,
		status: StatusMessageInfo,
		//A fix due to class struggle
		selectedDatePosition = '0-0',
		//Variables for creating new scheduled events
		start_date: Date | null,
		end_date: Date | null,
		title: string,
		description: string,
		event_id: number | undefined;

	export let type: 'user' | 'group';

	onMount(async () => {
		//Prevents "document not found" error
		deleteSelection = () => {
			document.getElementById(selectedDatePosition)?.classList.remove('selected');
		};

		setUpScheduledPolls();
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

	//This function is defined in onMount, prevents "document not found" error
	let deleteSelection = () => {};

	const setUpScheduledPolls = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			groupId ? `group/${groupId}/schedule` : 'user/schedule?limit=1000'
		);
		events = json.results;
	};

	const firstDayInMonthWeekday = () => {
		return new Date(year, month, 0).getDay();
	};

	const scheduleEventCreate = async (e: any) => {
		loading = true;
		const { res, json } = await fetchRequest('POST', `user/schedule/create`, {
			start_date,
			end_date,
			title,
			description: 'a'
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
		event_id = undefined;
	};

	const scheduleEventEdit = async (e: any) => {
		loading = true;
		const { res, json } = await fetchRequest('POST', `user/schedule/update`, {
			event_id,
			start_date,
			end_date,
			title,
			description: 'a'
		});

		loading = false;

		if (!res.ok) {
			status = statusMessageFormatter(res, json);
			return;
		}

		showEditScheduleEvent = false;
		show = true;
		events.push({
			created_by: Number(localStorage.getItem('userId')),
			description: '',
			end_date: end_date?.toString() || '',
			start_date: start_date?.toString() || '',
			event_id: json,
			score: 0,
			title,
			schedule_origin_name: 'user'
		});
		events = events;

		start_date = selectedDate;
		end_date = null;
		title = '';
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

		events.filter((event) => event.event_id === event_id);
		events = events;

		start_date = selectedDate;
		end_date = null;
		title = '';
		event_id = undefined;
	};

	const handleShowEditScheduleEvent = (event: scheduledEvent) => {
		start_date = new Date(event.start_date);
		end_date = new Date(event.end_date);
		title = event.title;
		description = event.description;
		event_id = event.event_id;
		showEditScheduleEvent = true;
	};

	$: if (showCreateScheduleEvent) {
		start_date = selectedDate
		end_date = addDateOffset(selectedDate, 1, 'hour');
	}

	// $: end_date = start_date ? addDateOffset(start_date, 1, 'hour') : new Date();
</script>

<div class={`flex bg-white dark:bg-darkobject dark:text-darkmodeText ${Class}`}>
	<div class="border-right-2 border-black p-4 pl-6 pr-6 w-1/4">
		{$_('Scheduled events for')}
		{selectedDate.getDate()}/{selectedDate.getMonth()}
		{selectedDate.getFullYear()}

		<div class="pt-3 pb-3">
			<div on:click={() => (showCreateScheduleEvent = true)} on:keydown>
				{#if type === 'user'}
					<Fa
						class="ml-auto mr-auto hover:bg-gray-200 dark:hover:bg-slate-700 transition p-3 cursor-pointer rounded"
						size="3x"
						icon={faPlus}
					/>
				{/if}
			</div>
			{#each events.filter((poll) => {
				//Fixes a one day off issue
				const date = new Date(poll.start_date);
				const fixedDate = new Date(date.setDate(date.getDate()));
				return fixedDate.toJSON().split('T')[0] === selectedDate.toJSON().split('T')[0];
			}) as event}
				<div class="mt-2">
					<a
						class="hover:underline cursor-pointer text-xs text-center color-black dark:text-darkmodeText text-black flex justify-between items-center gap-3"
						class:hover:bg-gray-300={event.poll}
						href={event.poll ? `groups/${event.group_id}/polls/${event.poll}` : location.href}
						on:click={() => {
							if (event.schedule_origin_name === 'user') handleShowEditScheduleEvent(event);
						}}
					>
						<span>{event.title}</span>
						<!-- {new Date(poll.start_date).getHours()}:{new Date(poll.start_date).getMinutes()} -->
						<span
							>{(() => {
								const startDate = new Date(event.start_date);
								return `${
									startDate.getHours() > 9 ? startDate.getHours() : '0' + startDate.getHours()
								}:${
									startDate.getMinutes() > 9 ? startDate.getMinutes() : '0' + startDate.getMinutes()
								}`;
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
				<div
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => (year -= 1)}
					on:keydown
				>
					<Fa icon={faChevronLeft} size="1.5x" />
				</div>
				<div class="text-xl text-center w-16">{year}</div>
				<div
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => (year += 1)}
					on:keydown
				>
					<Fa icon={faChevronRight} size="1.5x" />
				</div>
			</div>

			<div class="flex items-center ml-6 select-none">
				<div
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => (month -= 1)}
					on:keydown
				>
					<Fa icon={faChevronLeft} size="1.5x" />
				</div>
				<div class="w-10 text-center">{$_(months[month])}</div>
				<div
					class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
					on:click={() => (month += 1)}
					on:keydown
				>
					<Fa icon={faChevronRight} size="1.5x" />
				</div>
			</div>
		</div>
		<div class="calendar w-full">
			{#each [1, 2, 3, 4, 5, 6] as y}
				{#each [1, 2, 3, 4, 5, 6, 7] as x}
					<div
						class={`dark:text-darkmodeText relative calendar-day border-l border-t border-gray-400 select-none cursor-pointer text-gray-600 transition-all duration-20`}
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
							{#if events.filter((poll) => new Date(poll.start_date)
										.toJSON()
										.split('T')[0] === new Date(year, month, -firstDayInMonthWeekday() + x + 7 * (y - 1))
										.toJSON()
										.split('T')[0]).length > 0}
								<Fa class="m-auto" icon={faCalendarAlt} />
							{/if}
						</div>
					</div>
				{/each}
			{/each}
		</div>
	</div>
</div>

<!-- Modal for creating one's own/group scheduled event -->
<Modal bind:open={showCreateScheduleEvent}>
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
				<StatusMessage bind:status Class="w-full mt-3 mb-3" />
				<Button type="submit">{$_('Submit')}</Button>
			</form>
		</Loader>
	</div>
	<div slot="footer" />
</Modal>

<Modal bind:open={showEditScheduleEvent}>
	<div slot="header">Edit Event</div>
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
				<StatusMessage bind:status Class="w-full mt-3 mb-3" />
				<Button type="submit">{$_('Submit')}</Button>
				<Button buttonStyle="warning" action={scheduleEventDelete}>{$_('Delete')}</Button>
			</form>
		</Loader>
	</div>
</Modal>

<SuccessPoppup bind:show />

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

	.calendar-day {
		display: flex;
		justify-content: center;
	}

	.today {
		box-shadow: inset 0 0 0 2px var(--primary-color) !important;
	}

	.selected {
		box-shadow: inset 0 0 2px 3px var(--secondary-color) !important;
	}

	.calendar-day:hover {
		box-shadow: inset 0 0 2px 2px rgba(0, 0, 0, 0.1);
	}
</style>

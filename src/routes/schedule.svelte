<script lang="ts">
	import { onMount } from 'svelte';
	import { faChevronLeft } from '@fortawesome/free-solid-svg-icons/faChevronLeft';
	import { faChevronRight } from '@fortawesome/free-solid-svg-icons/faChevronRight';
	import Fa from 'svelte-fa/src/fa.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { scheduledEvent } from '$lib/Schedule/interface';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import Modal from '$lib/Generic/Modal.svelte';
	import { DateInput, DatePicker } from 'date-picker-svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import { formatDate } from '$lib/Generic/DateFormatter';

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

	const currentDate = new Date();
	let month = currentDate.getMonth(),
		year = currentDate.getFullYear(),
		selectedDate = new Date(),
		polls: scheduledEvent[] = [],
		loading = false,
		showCreateScheduleEventModal = false,
		//A fix due to class struggle
		selectedDatePosition = '0-0';

	$: month && year && deleteSelection();
	$: month && test();

	const test = () => {
		if (month === 12) {
			year += 1;
			month = 0;
		}
		if (month === -1) {
			year -= 1;
			month = 11;
		}
	};

	let deleteSelection = () => {};

	onMount(async () => {
		//Prevents "document not found" error
		deleteSelection = () => {
			document.getElementById(selectedDatePosition)?.classList.remove('selected');
		};

		setUpScheduledPolls();
	});

	const setUpScheduledPolls = async () => {
		const { json, res } = await fetchRequest('GET', 'user/schedule?limit=100');
		polls = json.results;
	};

	const firstDayInMonthWeekday = () => {
		return new Date(year, month, 0).getDay();
	};

	let start_date: Date, end_date: Date, title: string, description: string;

	$: start_date = new Date(selectedDate.setHours(0, 0, 0));
	$: end_date = new Date(selectedDate.setHours(23, 59, 59));

	const scheduleEventCreate = async (e: any) => {
		const { res, json } = await fetchRequest('POST', `user/schedule/create`, {
			start_date,
			end_date,
			title,
			description
		});
	};
</script>

<Layout>
	<div class="flex bg-white">
		<div class="border-right-2 border-black p-4 pl-6 pr-6 w-1/4">
			{$_('Scheduled events for')}
			{selectedDate.getDate()}/{selectedDate.getMonth() + 1}
			{selectedDate.getFullYear()}
			
			<div class="pt-3 pb-3">
				<div on:click={() => (showCreateScheduleEventModal = true)}>
					<Fa
						class="ml-auto mr-auto hover:bg-gray-200 transition p-3 cursor-pointer rounded"
						size="3x"
						icon={faPlus}
					/>
				</div>
				{#each polls.filter((poll) => {
					//Fixes a one day off issue
					const date = new Date(poll.start_date);
					const fixedDate = new Date(date.setDate(date.getDate()));
					return fixedDate.toJSON().split('T')[0] === selectedDate.toJSON().split('T')[0];
				}) as poll}
					<div class="mt-2">
						<a
							class="text-xs text-center color-black text-black cursor-default flex justify-between items-center gap-3"
							class:hover:bg-gray-300={poll.poll}
							href={poll.poll ? `groups/${poll.group_id}/polls/${poll.poll}` : location.href}
						>
							<span>{poll.title}</span>
							<!-- {new Date(poll.start_date).getHours()}:{new Date(poll.start_date).getMinutes()} -->
							<span
								>{(() => {
									const startDate = new Date(poll.start_date);
									return `${
										startDate.getHours() > 9 ? startDate.getHours() : '0' + startDate.getHours()
									}:${
										startDate.getMinutes() > 9
											? startDate.getMinutes()
											: '0' + startDate.getMinutes()
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
					<div class="cursor-pointer rounded-full hover:bg-gray-200" on:click={() => (year -= 1)}>
						<Fa icon={faChevronLeft} size="1.5x" />
					</div>
					<div class="text-xl text-center w-16">{year}</div>
					<div class="cursor-pointer rounded-full hover:bg-gray-200" on:click={() => (year += 1)}>
						<Fa icon={faChevronRight} size="1.5x" />
					</div>
				</div>

				<div class="flex items-center ml-6 select-none">
					<div class="cursor-pointer rounded-full hover:bg-gray-200" on:click={() => (month -= 1)}>
						<Fa icon={faChevronLeft} size="1.5x" />
					</div>
					<div class="w-10 text-center">{$_(months[month])}</div>
					<div class="cursor-pointer rounded-full hover:bg-gray-200" on:click={() => (month += 1)}>
						<Fa icon={faChevronRight} size="1.5x" />
					</div>
				</div>
			</div>
			<div class="calendar w-full">
				{#each [1, 2, 3, 4, 5, 6] as y}
					{#each [1, 2, 3, 4, 5, 6, 7] as x}
						<div
							class={` relative calendar-day border-l border-t border-gray-400 select-none cursor-pointer text-gray-600 transition-all duration-20`}
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
						>
							<div class="w-full">
								<div class="text-center">
									{new Date(year, month, -firstDayInMonthWeekday() + x + 7 * (y - 1)).getDate()}
								</div>
								<!-- {#each polls.filter((poll) => new Date(poll.start_date)
											.toJSON()
											.split('T')[0] === new Date(year, month, -firstDayInMonthWeekday() + x + 1 + 7 * (y - 1))
											.toJSON()
											.split('T')[0]) as poll}
									<p
										class="elipsis text-xs h-12 absolute w-full text-center max-h-[1rem] overflow-hidden"
									>
										{poll.title}
									</p>
								{/each} -->
								{#if polls.filter((poll) => new Date(poll.start_date)
											.toJSON()
											.split('T')[0] === new Date(year, month, -firstDayInMonthWeekday() + x + 1 + 7 * (y - 1))
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
</Layout>

<Modal bind:open={showCreateScheduleEventModal}>
	<div slot="header">{$_('Create Event')}</div>
	<div slot="body">
		<form on:submit|preventDefault={scheduleEventCreate}>
			<DateInput bind:value={start_date} format="yyyy-MM-dd HH:mm" />
			<DateInput value={end_date} format="yyyy-MM-dd HH:mm" />
			<TextInput label="Event title" bind:value={title} />
			<Button type="submit">{$_('Submit')}</Button>
		</form>
	</div>
	<div slot="footer" />
</Modal>

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

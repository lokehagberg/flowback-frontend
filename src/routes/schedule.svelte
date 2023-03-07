<script lang="ts">
	import Header from '$lib/Header/Header.svelte';
	import { onMount } from 'svelte';
	import { faCaretLeft } from '@fortawesome/free-solid-svg-icons/faCaretLeft';
	import { faChevronLeft } from '@fortawesome/free-solid-svg-icons/faChevronLeft';
	import { faChevronRight } from '@fortawesome/free-solid-svg-icons/faChevronRight';
	import { faArrowRight } from '@fortawesome/free-solid-svg-icons/faArrowRight';
	import Fa from 'svelte-fa/src/fa.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { scheduledEvent } from '$lib/Schedule/interface';

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
	let month = currentDate.getMonth();
	let year = currentDate.getFullYear();
	let selectedDate = new Date(year, month, 0);
	let polls: scheduledEvent[] = [];
	let loading = false;

	//A fix due to class struggle
	let selectedDatePosition = '0-0';

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
		const { json, res } = await fetchRequest('GET', 'poll/user/schedule?limit=100');
		polls = json.results;
	};

	const firstDayInMonthWeekday = () => {
		return new Date(year, month, 0).getDay();
	};
</script>

<Layout>
	<div class="flex bg-white">
		<div class="border-right-2 border-black p-4 pl-6 pr-6 w-1/4">
			{$_('Time polls at')}
			{selectedDate.getDate()}/{selectedDate.getMonth()}
			{selectedDate.getFullYear()}

			<div class="hover:bg-gray-300 pt-3 pb-3">
				{#each polls.filter((poll) => {
					//Fixes a one day off issue
					const date = new Date(poll.start_date);
					const fixedDate = new Date(date.setDate(date.getDate() - 1));
					return fixedDate.toJSON().split('T')[0] === selectedDate.toJSON().split('T')[0];
				}) as poll}
					<a
						class="text-center color-black"
						href={`groups/${poll.group_id}/polls/${poll.poll}`}
					>
						{poll.title}
						{new Date(poll.start_date).getHours()}:{new Date(poll.start_date).getMinutes()}
					</a>
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
							class={` relative calendar-day border-l border-t border-gray-400 select-none cursor-pointer text-gray-600 transition-all duration-200`}
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
								{#each polls.filter((poll) => new Date(poll.start_date)
											.toJSON()
											.split('T')[0] === new Date(year, month, -firstDayInMonthWeekday() + x + 1 + 7 * (y - 1))
											.toJSON()
											.split('T')[0]) as poll}
									<p
										class="elipsis text-xs h-12 absolute w-full text-center max-h-[1rem] overflow-hidden"
									>
										{poll.title}
									</p>
								{/each}
							</div>
						</div>
					{/each}
				{/each}
			</div>
		</div>
	</div>
</Layout>

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
		box-shadow: inset 0 0 0 2px var(--primary-color);
	}

	.selected {
		box-shadow: inset 0 0 2px 3px var(--secondary-color);
	}
</style>

<script lang="ts">
	import Header from '$lib/Header/Header.svelte';
	import { onMount } from 'svelte';
	import './schedule.css';
	import { faCaretLeft } from '@fortawesome/free-solid-svg-icons/faCaretLeft';
	import { faChevronLeft } from '@fortawesome/free-solid-svg-icons/faChevronLeft';
	import { faChevronRight } from '@fortawesome/free-solid-svg-icons/faChevronRight';
	import { faArrowRight } from '@fortawesome/free-solid-svg-icons/faArrowRight';
	import Fa from 'svelte-fa/src/fa.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
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
	let polls = [];
	let loading = false;

	//A fix due to class struggle
	let selectedDatePosition = '0-0';

	$: month && year && deleteSelection();
	$: month && test();

	const test = () => {
		if (month === 12) {
			year += 1;
			month = 0;
			console.log('hi');
		}
		if (month === -1) {
			year -= 1;
			month = 11;
		}
	};

	let deleteSelection = () => {};

	onMount(() => {
		deleteSelection = () => {
			document.getElementById(selectedDatePosition)?.classList.remove('selected');
		};
	});

	const firstDayInMonthWeekday = () => {
		return new Date(year, month, 0).getDay();
	};
</script>

<Layout>
	<div class="flex bg-white">
		<div class="border-right-2 border-black p-4 pl-6 pr-6 w-1/4">
			Time polls at {selectedDate.getDate()}/{selectedDate.getMonth()}
			{selectedDate.getFullYear()}
			<div>13:00 Meeting</div>
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
					<div class="w-10 text-center">{months[month]}</div>
					<div class="cursor-pointer rounded-full hover:bg-gray-200" on:click={() => (month += 1)}>
						<Fa icon={faChevronRight} size="1.5x" />
					</div>
				</div>
			</div>
			<div class="calendar w-full">
				<!-- {@debug selectedDate} -->
				{#each [1, 2, 3, 4, 5, 6] as y}
					{#each [1, 2, 3, 4, 5, 6, 7] as x}
						<div
							class="calendar-day border-l border-t border-gray-400 select-none cursor-pointer text-gray-600 "
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
							{new Date(year, month, -firstDayInMonthWeekday() + x + 7 * (y - 1)).getDate()}
						</div>
					{/each}
				{/each}
			</div>
		</div>
	</div>
</Layout>

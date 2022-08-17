<script lang="ts">
	import Header from '$lib/Header/Header.svelte';
	import { onMount } from 'svelte';
	import './schedule.css';
	import { faCaretLeft } from '@fortawesome/free-solid-svg-icons/faCaretLeft';
	import { faArrowRight } from '@fortawesome/free-solid-svg-icons/faArrowRight';
	import Fa from 'svelte-fa/src/fa.svelte';
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

	//A fix due to class struggle
	let selectedDatePosition = '0-0';

	$: month && year && deleteSelection();

	let deleteSelection = () => {};

	onMount(() => {
		deleteSelection = () => {
			document.getElementById(selectedDatePosition)?.classList.remove('selected');
		};
	});

	let polls = [];
	let loading = false;
	let pollList = [];

	const firstDayInMonthWeekday = () => {
		return new Date(year, month, 0).getDay();
	};

	const lastDayInMonth = () => {
		return new Date(year, month + 1, 0).getDate();
	};
</script>

<Header />

<div class="flex items-center">
	<div class="cursor-pointer bg-blue-500 rounded-lg" on:click={() => (year -= 1)}><Fa icon={faCaretLeft} color="white" size="2.5x"/></div>
	<div class="text-xl">{year}</div>
	<div class="cursor-pointer " on:click={() => (year += 1)}><Fa icon={faArrowRight}/></div>
</div>

<div>
	<div on:click={() => (month -= 1)}>{'<'}</div>
	{months[month]}
	<div on:click={() => (month += 1)}>{'>'}</div>
</div>

<div class="calendar">
	<!-- {@debug selectedDate} -->
	{#each [1, 2, 3, 4, 5, 6] as y}
		{#each [1, 2, 3, 4, 5, 6, 7] as x}
			<div
				class="calendar-day border border-xs border-gray-400"
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

<div>
	Time polls at {selectedDate.getDate()}/{selectedDate.getMonth()}
	{selectedDate.getFullYear()}
	<div>13:00 Pump oil somewhere</div>
</div>

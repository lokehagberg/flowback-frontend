<script lang="ts">
	import Header from '$lib/Header/Header.svelte';

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
	let selectedDate = currentDate;
	let polls = [];
	let loading = false;
	let pollList = [];

	function firstDayInMonthWeekday() {
		return new Date(year, month, 0).getDay();
	}

	console.log(firstDayInMonthWeekday());
</script>

<Header />

<div on:click={() => (year -= 1)}>{'<'}</div>
{year}
<div on:click={() => (year += 1)}>{'>'}</div>

<div on:click={() => (month -= 1)}>{'<'}</div>
{months[month]}
<div on:click={() => (month += 1)}>{'>'}</div>

<div class="calendar">
	{#each [1, 2, 3, 4, 5, 6] as y}
		{#each [1, 2, 3, 4, 5, 6, 7] as x}
			{@debug selectedDate}
			<div
				class="calendar-day border border-xs border-gray-400"
				class:today={-firstDayInMonthWeekday() + x + 7 * (y - 1) === currentDate.getDate() &&
					month === currentDate.getMonth() &&
					year === currentDate.getFullYear()}
				class:selected={-firstDayInMonthWeekday() + x + 7 * (y - 1) === selectedDate.getDate() &&
					month === selectedDate.getMonth() &&
					year === selectedDate.getFullYear()}
				on:click={() =>
					(selectedDate = new Date(year, month, -firstDayInMonthWeekday() + x + 7 * (y - 1)))}
			>
				{new Date(year, month, -firstDayInMonthWeekday() + x + 7 * (y - 1)).getDate()}
			</div>
		{/each}
	{/each}
</div>

<style>
	.calendar {
		display: grid;
		grid-template-columns: repeat(7, clamp(40px, 8vw, 100px));
		grid-template-rows: repeat(7, clamp(40px, 8vw, 100px));
	}

	.calendar-day {
		display: flex;
		justify-content: center;
		align-items: center;
	}

	.today {
		background: blue;
	}

	.selected {
		background: green;
	}
</style>

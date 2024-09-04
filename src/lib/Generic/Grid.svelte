<script lang="ts">
	import { faCheck } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import { getMonday, getWeek } from './Dates';
	import { onMount } from 'svelte';

	export let x = 10,
		y = 10;
	// w = 200,
	// h = 300;

	let clicked = [[1, 1]],
		selectedDates: Date[] = [],
		week: number = getWeek(new Date()),
		year: number = new Date().getFullYear(),
		monday: Date;

	onMount(() => {
		monday = getRecentMonday(new Date());
	});

	const getRecentMonday = (d: Date) => {
		let mondayOffset = d.getDate() - d.getDay() + 1;
		let month = mondayOffset < 0 ? d.getMonth() - 1 : d.getMonth();

		return new Date(d.getFullYear(), month, mondayOffset);
	};
</script>

<button on:click={() => year++}>year up</button>
<button on:click={() => year--}>year down</button>
<button on:click={() => week++}>week up</button>
<button on:click={() => week--}>week down</button>

{year}
{week}

{selectedDates.length}

{#if monday}
	<div
		class="grid"
		style={`grid-template-columns: repeat(${x}, 1fr); grid-template-rows: repeat(${y}, 1fr);`}
	>
		{#each { length: y } as _, j}
			{#each { length: x } as _, i}
				{@const date = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + i, j)}
				<div
					class="border p-4"
					on:click={() => {
						// clicked.push([i, j]);
						// clicked = clicked;
						selectedDates.push(date);
						selectedDates = selectedDates;
						console.log(
							date,
							selectedDates,
							'CAN YOU HERE THE BEAT?',
							selectedDates.find((_date) => _date === date)
						);
					}}
					on:keydown
					role="button"
					tabindex="0"
				>
					{date}
					{selectedDates}
					{#key selectedDates}
					{selectedDates.findIndex((_date) => _date === date)}
						{#if selectedDates.find((_date) => _date === date)}zzz
							<div class="bg-green-600 p-6"><Fa icon={faCheck} color="white" /></div>
						{:else}
							<slot {i} {j} />
						{/if}
					{/key}
				</div>
			{/each}
		{/each}
	</div>
{/if}

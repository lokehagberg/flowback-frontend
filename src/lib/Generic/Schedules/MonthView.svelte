<script lang="ts">
	import { faCheck } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';

	export let x = 7,
		y = 7,
		start_date,
		area_vote_end_date,
		proposal_end_date,
		prediction_statement_end_date,
		prediction_bet_end_date,
		delegate_vote_end_date,
		vote_end_date,
		end_date;
	// w = 200,
	// h = 300;

	let selectedDates: Date[] = [],
		weekOffset: number = 0,
		year: number = new Date().getFullYear(),
		initialMonday: Date,
		monday: Date;

	onMount(() => {
		initialMonday = getRecentMonday(new Date());
	});

	const getRecentMonday = (d: Date) => {
		let mondayOffset = d.getDate() - d.getDay() + 1;
		let month = mondayOffset < 0 ? d.getMonth() - 1 : d.getMonth();

		return new Date(d.getFullYear(), month, mondayOffset);
	};

	const toggleDate = (date: Date) => {
		const before = selectedDates.find((_date) => _date?.getTime() === date?.getTime());
		if (before)
			selectedDates = selectedDates.filter((_date) => _date?.getTime() !== date?.getTime());
		else selectedDates.push(date);

		selectedDates = selectedDates;
	};

	const saveSelection = async () => {
		const array = selectedDates.map(async (date) => {
			const start_date = date;
			const end_date = new Date(
				date.getFullYear(),
				date.getMonth(),
				date.getDate(),
				date.getHours() + 1
			);

			try {
				const { res, json } = await fetchRequest(
					'POST',
					`group/poll/${$page.params.pollId}/proposal/create`,
					{
						start_date,
						end_date
					}
				);
			} catch {
				const { res, json } = await fetchRequest(
					'POST',
					`group/poll/${$page.params.pollId}/proposal/vote/update`,
					{
						start_date,
						end_date
					}
				);
			}
		});

		let output = await Promise.allSettled(array);
	};

	const setUpDraggable = async () => {
		const { Swappable, Draggable, Sortable, SortAnimation } = await import('@shopify/draggable');
		const draggable = new Swappable(document.getElementById('monthView'), {
			draggable: 'swappable'
		});

	};

	onMount(() => {
		setUpDraggable();
	});

	$: monday = getRecentMonday(
		new Date(
			initialMonday?.getFullYear(),
			initialMonday?.getMonth(),
			initialMonday?.getDate() + weekOffset * 7
		)
	);

	$: gridDates = Array.from({ length: y }, (_, j) =>
		Array.from(
			{ length: x },
			(_, i) => new Date(monday?.getFullYear(), monday?.getMonth(), monday?.getDate() + i + j * 7)
		)
	);
</script>

<button on:click={() => year++}>year up</button>
<button on:click={() => year--}>year down</button>
<button on:click={() => weekOffset++}>week up</button>
<button on:click={() => weekOffset--}>week down</button>
<button on:click={saveSelection}>le submit</button>

{year}
{weekOffset}

{#key weekOffset}
	{#if monday}
		<div
			class="grid"
			style={`grid-template-columns: repeat(${x}, 1fr); grid-template-rows: repeat(${y}, 1fr);`}
			id="monthView"
		>
			{#each gridDates as row, j}
				{#each row as date, i}
					<div class="border p-4" on:keydown role="button" tabindex="0">
						{date}

						<swappable
							id={`${x}-${y}-draggable`}
							class="py-5 px-1"
							class:!bg-blue-600={true && date.getDate() === 10}
						/>
						<!--
						{#if selectedDates.find((_date) => _date?.getTime() === date?.getTime())}
							<div class="bg-green-600 p-6"><Fa icon={faCheck} color="white" /></div>
						{:else}
							<slot {i} {j} />
						{/if}
					-->
					</div>
				{/each}
			{/each}
		</div>
	{/if}
{/key}

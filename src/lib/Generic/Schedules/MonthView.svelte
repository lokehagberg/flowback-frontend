<script lang="ts">
	import { faCheck } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import { onMount, tick } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';

	export let x = 7,
		y = 7,
		start_date: Date,
		area_vote_end_date: Date,
		proposal_end_date: Date,
		prediction_statement_end_date: Date,
		prediction_bet_end_date: Date,
		delegate_vote_end_date: Date,
		vote_end_date: Date,
		end_date: Date;
	// w = 200,
	// h = 300;

	let selectedDates: Date[] = [],
		weekOffset: number = 0,
		year: number = new Date().getFullYear(),
		initialMonday: Date,
		monday: Date,
		mounted: boolean,
		dates: Date[] = [];

	onMount(() => {
		mounted = true;
		initialMonday = getRecentMonday(new Date());
		dates = [
			start_date,
			area_vote_end_date,
			proposal_end_date,
			prediction_statement_end_date,
			prediction_bet_end_date,
			delegate_vote_end_date,
			vote_end_date,
			end_date
		];
		dates.map((date) => date.setHours(0, 0, 0, 0));
		dates = dates;
	});

	const getRecentMonday = (d: Date) => {
		let mondayOffset = d.getDate() - d.getDay() + 1;
		let month = mondayOffset < 0 ? d.getMonth() - 1 : d.getMonth();

		return new Date(d.getFullYear(), month, mondayOffset);
	};

	const setUpDraggable = async () => {
		const { Swappable } = await import('@shopify/draggable');
		const draggable = new Swappable(document.getElementById('monthView'), {
			draggable: 'swappable'
		});

		draggable.on('drag:stop', (e: any) => {
			// console.log(e.source.parentElement);
			// console.log(e.source.parentElement.id[0]);
			let x: string = e.source.parentElement.id[0];
			let y: string = e.source.parentElement.id[2];
			console.log(e.originalSource.id);

			// tick();
			const newDate = new Date(
				monday?.getFullYear(),
				monday?.getMonth(),
				monday?.getDate() + Number(x) + Number(y) * 7
			);

			if (dates.find(_date => _date.getTime() === newDate.getTime())) {
				// e.cancel();
				// return;
			} 
			console.log('New day new beginnings',);
			

			//TODO: General refactor on phases so it only uses arrays for dynamic number of phases
			//Note: Do not do code like this like ever.

			switch (e.originalSource.id) {
				case '0':
					start_date = newDate;
					break;
				case '1':
					area_vote_end_date = newDate;
					break;
				case '2':
					proposal_end_date = newDate;
					break;
				case '3':
					prediction_statement_end_date = newDate;
					break;
				case '4':
					prediction_bet_end_date = newDate;
					break;
				case '5':
					delegate_vote_end_date = newDate;
					break;
				case '6':
					vote_end_date = newDate;
					break;
				case '7':
					end_date = newDate;
					break;
				default:
					break;
			}

			// start_date =

			// console.log(start_date, monday, x, y);
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

{year}
{weekOffset}

<!-- {#key weekOffset} -->
	{#if monday}
		<div
			class="grid"
			style={`grid-template-columns: repeat(${x}, 1fr); grid-template-rows: repeat(${y}, 1fr);`}
			id="monthView"
		>
			{#each gridDates as row, j}
				{#each row as date, i}
					{@const index = dates.findIndex((_date) => _date.getTime() === date.getTime())}
					<div id={`${i}-${j}-draggable`} class="border p-4" on:keydown role="button" tabindex="0">
						<!-- {date}
						{new Date(dates[0]?.getFullYear(), dates[0]?.getMonth(), dates[0]?.getDate())}
						{date.getTime() ===
							new Date(
								start_date.getFullYear(),
								start_date.getMonth(),
								start_date.getDate()
							).getTime()} -->

							{date.getDate()}
						<swappable
							id={index}
							class="py-5 px-5"
							class:!bg-blue-600={mounted &&
								date.getTime() ===
									new Date(
										dates.find((_date) => _date.getTime() === date.getTime())?.getFullYear() || 0,
										dates.find((_date) => _date.getTime() === date.getTime())?.getMonth() || 0,
										dates.find((_date) => _date.getTime() === date.getTime())?.getDate()
									)?.getTime()}><span id={index?.toString()} /></swappable
						>
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
<!-- {/key} -->

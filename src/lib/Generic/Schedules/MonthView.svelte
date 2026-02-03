<script lang="ts">
	import { faChevronLeft, faChevronRight } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import { onMount } from 'svelte';

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

	let selectedDates: Date[] = [],
		weekOffset: number = 0,
		year: number = new Date().getFullYear(),
		initialMonday: Date,
		monday: Date,
		mounted: boolean,
		dates: Date[] = [];

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
			let x: string = e.source.parentElement.id[0];
			let y: string = e.source.parentElement.id[2];

			const newDate = new Date(
				monday?.getFullYear(),
				monday?.getMonth(),
				monday?.getDate() + Number(x) + Number(y) * 7
			);

			if (dates.find((_date) => _date.getTime() === newDate.getTime())) {
				// e.cancel();
				// return;
			}

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
		});
	};

	onMount(() => {
		setUpDraggable();

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

<div class="flex">
	<!-- Buttons that the user presses to go between years or weeks -->
	<div class="flex items-center select-none">
		<!-- Had to include type="button" due to an odd bug where these buttons would act as submit buttons in forms -->
		<button
			class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
			on:click={() => year--}
			type="button"
		>
			<Fa icon={faChevronLeft} size="1.5x" />
		</button>
		<div class="text-xl text-center w-16">{year}</div>

		<button
			class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
			on:click={() => year++}
			type="button"
		>
			<Fa icon={faChevronRight} size="1.5x" />
		</button>
	</div>

	<div class="flex items-center ml-6 select-none">
		<button
			class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
			on:click={() => weekOffset--}
			type="button"
		>
			<Fa icon={faChevronLeft} size="1.5x" />
		</button>

		{(() => {
			let date = new Date();
			date.setDate(date.getDate() + 7 * weekOffset);
			year = date.getFullYear();
			//@ts-ignore
			return date.getWeek();
		})()}

		<!-- {weekDisplay()} -->

		<button
			class="cursor-pointer rounded-full hover:bg-gray-200 dark:hover:bg-slate-700"
			on:click={() => weekOffset++}
			type="button"
		>
			<Fa icon={faChevronRight} size="1.5x" />
		</button>
	</div>
</div>

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
				{@const isSelected =
					mounted &&
					date.getTime() ===
						new Date(
							dates.find((_date) => _date.getTime() === date.getTime())?.getFullYear() || 0,
							dates.find((_date) => _date.getTime() === date.getTime())?.getMonth() || 0,
							dates.find((_date) => _date.getTime() === date.getTime())?.getDate()
						)?.getTime()}

				<div id={`${i}-${j}-draggable`} class="border p-4">
					{date.getDate()}
					<swappable id={index} class="p-5"
						><span id={index?.toString()} />

						{#if isSelected}
							<svg width="50" height="100" viewBox="0 0 50 100" xmlns="http://www.w3.org/2000/svg">
								<!-- Vertical line -->
								<line x1="25" y1="20" x2="25" y2="90" stroke="#0D47A1" stroke-width="4" />

								<!-- Top circle anchor point -->
								<circle cx="25" cy="20" r="12" fill="#0D47A1" />

								<text x="25" y="25" font-size="14" fill="white" text-anchor="middle"
									>{index + 1}</text
								>
							</svg>
						{/if}
					</swappable>
				</div>
			{/each}
		{/each}
	</div>
{/if}

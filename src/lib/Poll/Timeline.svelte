<script lang="ts">
	import { formatDate } from '$lib/Generic/DateFormatter';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import { faSquareCheck } from '@fortawesome/free-solid-svg-icons/faSquareCheck';
	import { faSquareFull } from '@fortawesome/free-solid-svg-icons/faSquareFull';
	import { _ } from 'svelte-i18n';

	export let displayDetails = true,
		displayTimeline = true,
		Class = '';
	export let dates: Date[] = [];
	let datesDisplay: string[] = [];

	let date = new Date();
	// const dateLabels = ["Start", "Proposal end", "Delegate end", "End"]
	const dateLabels = ['Start date', 'Proposal vote date', 'Delegate vote date', 'End date'];
	const totalTime = dates[dates.length - 1].getTime() - dates[0].getTime();

	// Difference between now and start date
	const toNowTime = date.getTime() - dates[0].getTime();
	let progress = (100 * toNowTime) / totalTime;

	let datePlacement: number[] = [];
	dates.forEach((date, i) => {
		// Date placement on Timeline
		const toDateTime = date.getTime() - dates[0].getTime();
		datePlacement[i] = (100 * toDateTime) / totalTime;
		datesDisplay[i] = formatDate(date.toString())
	});
</script>

<div class={`relative text-black p-4 border border-gray-200 rounded ${Class}`}>
	{#if displayTimeline}
		<h1 class="text-left text-2xl">{$_('Timeline')}</h1>
		<!-- {#if import.meta.env.VITE_PROD === 'PROD'} -->
			<div class="h-4">
				{#each datePlacement as date, i}
					<div class="absolute z-20" style:left={`calc(${date}% - 0.75rem)`}>
						<HeaderIcon
							Class="cursor-default"
							size="1.5x"
							text={`${$_(dateLabels[i])}: ${datesDisplay[i]}`}
							icon={dates[i] <= new Date() ? faSquareCheck : faSquareFull}
							color={`${dates[i] <= new Date() ? '#015BC0' : ''}`}
						/>
					</div>
				{/each}
			</div>
		<!-- {/if} -->
		<div class="h-10 mt-2">
			<div class={`absolute bg-gray-300 left-0 h-6 rounded-full w-full`} />
			<div
				class={`absolute bg-blue-400 left-0 h-6 rounded-full`}
				style:width={`${progress < 100 ? progress : 100}%`}
			/>
		</div>
	{/if}
	{#if displayDetails}
		<ul class="border border-gray-200 p-4">
			{#each dateLabels as label, i}
				<li class="flex justify-between flex-col md:flex-row text-center">
					<div class="mb-4 md:mb-0">{$_(label)}:</div>
					<div class="mb-4 md:mb-0">{datesDisplay[i]} CET</div>
				</li>
			{/each}
		</ul>
	{/if}
</div>

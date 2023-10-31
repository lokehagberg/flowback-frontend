<script lang="ts">
	import { formatDate } from '$lib/Generic/DateFormatter';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import { faSquareCheck } from '@fortawesome/free-solid-svg-icons/faSquareCheck';
	import { faSquareFull } from '@fortawesome/free-solid-svg-icons/faSquareFull';
	import { faDownLong } from '@fortawesome/free-solid-svg-icons/faDownLong';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';

	export let displayDetails = true,
		displayTimeline = true,
		Class = '';
	export let dates: Date[] = [];
	let datesDisplay: string[] = [];

	const dateLabels = [
		'Tag',
		'Proposals',
		'Prediction statements',
		'Prediction betting',
		'Delegate lock-in',
		'Voting',
		'Results and Evaluation'
	];

	const currentPhase = dates.findLastIndex((date:Date) => new Date(date) <= new Date())
	const fraction = currentPhase / dates.length	

	const totalTime = dates[dates.length - 1].getTime() - dates[0].getTime();

	let datePlacement: number[] = [];
	dates.forEach((date, i) => {
		// Date placement on Timeline
		const toDateTime = date.getTime() - dates[0].getTime();
		datePlacement[i] = (100 * toDateTime) / totalTime;
		datesDisplay[i] = formatDate(date.toString());
	});
</script>

<div class={`relative ${Class}`}>
	{#if displayTimeline}
		<div
			class="flex justify-between mt-2 rounded-md"
			style={`background: linear-gradient(90deg, rgba(89, 158, 255, 1) ${fraction * 100 - 2}%, rgba(191, 191, 191, 1) ${fraction * 100}%`}
		>
			{#each datePlacement as date, i}
				<div class="h-6">
					<HeaderIcon
						Class="cursor-default !p-0"
						size="1.5x"
						text={`${$_(dateLabels[i])}: ${datesDisplay[i]}`}
						icon={dates[i] <= new Date() ? faSquareCheck : faSquareFull}
						color={`${dates[i] <= new Date() ? '#015BC0' : ''}`}
					/>
				</div>
			{/each}
		</div>
	{/if}
	{#if displayDetails}
		<ul class="p-2">
			<div
				on:keydown={() => {}}
				class="hover:underline flex items-center gap-2 cursor-pointer"
				on:click={() => (displayDetails = false)}
			>
				<Fa icon={faDownLong} flip />
				{$_('Time details')}
			</div>
			{#each dateLabels as label, i}
				<li class="flex justify-between flex-col md:flex-row text-center">
					<div class="mb-4 md:mb-0">{$_(label)}:</div>
					<div class="mb-4 md:mb-0">{datesDisplay[i]} CET</div>
				</li>
			{/each}
		</ul>
	{:else}
		<ul
			on:keydown={() => {}}
			class="hover:underline flex items-center gap-1 cursor-pointer text-xs mb-3"
			on:click={() => (displayDetails = true)}
		>
			<Fa icon={faDownLong} />
			{$_('Time details')}
		</ul>
	{/if}
</div>
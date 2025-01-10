<script lang="ts">
	import { formatDate } from '$lib/Generic/DateFormatter';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import { faDownLong } from '@fortawesome/free-solid-svg-icons/faDownLong';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { dateLabels as dateLabelsTextPoll, dateLabelsDatePoll } from '../functions';
	import {
		faCircle,
		faCircleCheck,
		faCircleExclamation,
		faMinus
	} from '@fortawesome/free-solid-svg-icons';
	import type { Phase, poll } from '../interface';
	import { onMount } from 'svelte';

	export let displayDetails = true,
		displayTimeline = true,
		Class = '',
		dates: Date[] = [],
		pollType: number,
		poll: poll,
		phase:Phase;

	let datesArray: string[] = [],
		dateLabels = pollType === 4 ? dateLabelsTextPoll : dateLabelsDatePoll,
		currentPhaseIndex: number,
		fraction: number,
		datePlacement: number[] = [];

	onMount(() => {
		setupDates();
	});

	$: if (phase) {
		dates[currentPhaseIndex] = dates[currentPhaseIndex - 1]
		currentPhaseIndex++;
		setupDates();
	}

	const setupDates = () => {
		//Code has been setup to make it really easy to add or remove dates. Perhaps expand on that?
		dates = [
			new Date(poll.start_date),
			new Date(poll.area_vote_end_date),
			new Date(poll.proposal_end_date),
			new Date(poll.prediction_statement_end_date),
			new Date(poll.prediction_bet_end_date),
			new Date(poll.delegate_vote_end_date),
			new Date(poll.end_date)
		];

		currentPhaseIndex = dates.findLastIndex((date: Date) => new Date(date) <= new Date());
		fraction = (currentPhaseIndex + 1) / dates.length;

		let totalTime = dates[dates.length - 1].getTime() - dates[0].getTime();

		dates.forEach((date, i) => {
			// Date placement on Timeline
			const toDateTime = date.getTime() - dates[0].getTime();
			datePlacement[i] = (100 * toDateTime) / totalTime;
			datesArray[i] = formatDate(date.toString());
		});
	};
</script>

{#key phase}
<div class={`relative flex flex-col items-center ${Class}`}>
	<div class="text-center">
		<span class="font-semibold text-primary">
			{$_('Current')}:
		</span>
		{$_('Phase')}
		{currentPhaseIndex + 1}.
		{$_(dateLabels[currentPhaseIndex])}
	</div>

	{#if displayTimeline}
		<div
			class="mt-4 flex flex-col gap-20 justify-between rounded-md max-w-4"
			style={`background: linear-gradient(180deg, rgba(189, 208, 255, 1) ${
				fraction * 100 - 2
			}%, rgba(191, 191, 191, 1) ${fraction * 100}%`}
		>
			{#each datePlacement as date, i}
				{@const icon =
					i === currentPhaseIndex
						? faCircleExclamation
						: dates[i] <= new Date()
						? faCircleCheck
						: faCircle}

				<HeaderIcon
					Class="cursor-default"
					size="1x"
					text={`${$_(dateLabels[i])}: ${datesArray[i]}`}
					{icon}
					color={`${dates[i] <= new Date() ? '#015BC0' : ''}`}
				/>
			{/each}
		</div>
	{/if}
	{#if displayDetails}
		<ul class="p-2">
			<button
				class="hover:underline flex items-center gap-2 cursor-pointer"
				on:click={() => (displayDetails = false)}
			>
				<Fa icon={faDownLong} flip />
				{$_('Time details')}
			</button>
			{#each dateLabels as label, i}
				<li class="flex justify-between flex-col md:flex-row text-center">
					<div class="mb-4 md:mb-0">{$_(label)}:</div>
					<div class="mb-4 md:mb-0">{datesArray[i]} CET</div>
				</li>
			{/each}
		</ul>
	{:else if displayDetails}
		<button
			class="hover:underline flex items-center gap-1 cursor-pointer text-xs"
			on:click={() => (displayDetails = true)}
		>
			<Fa icon={faDownLong} />
			{$_('Time details')}
		</button>
	{/if}
</div>
{/key}
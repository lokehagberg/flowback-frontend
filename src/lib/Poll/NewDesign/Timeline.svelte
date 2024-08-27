<script lang="ts">
	import { formatDate } from '$lib/Generic/DateFormatter';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import { faDownLong } from '@fortawesome/free-solid-svg-icons/faDownLong';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';
	import { dateLabels as dateLabelsTextPoll, dateLabelsDatePoll } from '../functions';
	import { faCircle, faCircleCheck } from '@fortawesome/free-solid-svg-icons';
	import type { poll } from '../interface';
	import { onMount } from 'svelte';

	export let displayDetails = true,
		displayTimeline = true,
		Class = '',
		dates: Date[] = [],
		pollType: number,
		poll: poll;

	let datesDisplay: string[] = [],
		dateLabels = pollType === 4 ? dateLabelsTextPoll : dateLabelsDatePoll,
		currentPhase,
		fraction: number,
		datePlacement: number[] = [];

	onMount(() => {
		setupDates();
	});

	const setupDates = () => {
		dates = [
			new Date(poll.start_date),
			new Date(poll.area_vote_end_date),
			new Date(poll.proposal_end_date),
			new Date(poll.prediction_statement_end_date),
			new Date(poll.prediction_bet_end_date),
			new Date(poll.delegate_vote_end_date),
			new Date(poll.end_date)
		];

		currentPhase = dates.findLastIndex((date: Date) => new Date(date) <= new Date());
		fraction = (currentPhase + 1) / dates.length;

		let totalTime = dates[dates.length - 1].getTime() - dates[0].getTime();

		dates.forEach((date, i) => {
			// Date placement on Timeline
			const toDateTime = date.getTime() - dates[0].getTime();
			datePlacement[i] = (100 * toDateTime) / totalTime;
			datesDisplay[i] = formatDate(date.toString());
		});
	};
</script>

<div class={`relative ${Class}`}>
	{#if displayTimeline}
		<div
			class="flex flex-col gap-20 justify-between rounded-md max-w-4"
			style={`background: linear-gradient(180deg, rgba(189, 208, 255, 1) ${
				fraction * 100 - 2
			}%, rgba(191, 191, 191, 1) ${fraction * 100}%`}
		>
			{#each datePlacement as date, i}
				<div class="">
					<HeaderIcon
						Class="cursor-default"
						size="1x"
						text={`${$_(dateLabels[i])}: ${datesDisplay[i]}`}
						icon={dates[i] <= new Date() ? faCircleCheck : faCircle}
						color={`${dates[i] <= new Date() ? '#015BC0' : ''}`}
					/>
				</div>
			{/each}
		</div>
	{/if}
	{#if displayDetails}
		<ul class="p-2">
			<!-- svelte-ignore a11y-no-static-element-interactions -->
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
	{:else if displayDetails}
		<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
		<ul
			on:keydown={() => {}}
			class="hover:underline flex items-center gap-1 cursor-pointer text-xs"
			on:click={() => (displayDetails = true)}
		>
			<Fa icon={faDownLong} />
			{$_('Time details')}
		</ul>
	{/if}
</div>

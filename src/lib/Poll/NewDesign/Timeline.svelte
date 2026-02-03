<script lang="ts">
	import { formatDate } from '$lib/Generic/DateFormatter';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import { faDownLong } from '@fortawesome/free-solid-svg-icons/faDownLong';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { dateLabels as dateLabelsTextPoll, dateLabelsDatePoll } from '../functions';
	import { faCircle, faCircleCheck, faCircleExclamation } from '@fortawesome/free-solid-svg-icons';
	import type { Phase, poll } from '../interface';

	export let enableDetails = false,
		displayTimeline = true,
		Class = '',
		dates: Date[] = [],
		poll: poll,
		phase: Phase,
		horizontal = false,
		displayTimelinePhase = true;

	let datesArray: string[] = [],
		displayDetails = false,
		dateLabels = poll?.poll_type === 4 ? dateLabelsTextPoll : dateLabelsDatePoll,
		currentPhaseIndex: number,
		fraction: number,
		datePlacement: number[] = [];

	const setupDates = () => {
		//Code has been setup to make it really easy to add or remove dates. Perhaps expand on that?
		dates = [];

		if (poll?.poll_type === 4) {
			dates = [
				new Date(poll?.start_date),
				new Date(poll?.area_vote_end_date),
				new Date(poll?.proposal_end_date),
				new Date(poll?.prediction_statement_end_date),
				new Date(poll?.prediction_bet_end_date),
				new Date(poll?.delegate_vote_end_date),
				new Date(poll?.end_date)
			];

			//TODO: Refactor so this works by making it easy for varying number of phases.
			if (phase === 'area_vote' || phase === 'pre_start') {
				currentPhaseIndex = 0;
			} else if (phase === 'proposal') {
				currentPhaseIndex = 1;
			} else if (phase === 'prediction_statement') {
				currentPhaseIndex = 2;
			} else if (phase === 'prediction_bet') {
				currentPhaseIndex = 3;
			} else if (phase === 'delegate_vote') {
				currentPhaseIndex = 4;
			} else if (phase === 'vote') {
				currentPhaseIndex = 5;
			} else if (phase === 'result' || phase === 'prediction_vote') {
				currentPhaseIndex = 6;
			}
		} else if (poll?.poll_type === 3) {
			dates = [new Date(poll?.start_date), new Date(poll?.end_date)];

			//TODO: Refactor so this works by making it easy for varying number of phases.
			if (dates[1] > new Date()) {
				currentPhaseIndex = 0;
			} else {
				currentPhaseIndex = 1;
			}
		}

		fraction = (currentPhaseIndex + 1) / dates.length;

		let totalTime = dates[dates.length - 1].getTime() - dates[0].getTime();

		dates.forEach((date, i) => {
			// Date placement on Timeline
			const toDateTime = date.getTime() - dates[0].getTime();
			datePlacement[i] = (100 * toDateTime) / totalTime;
			datesArray[i] = formatDate(date.toString());
		});
	};

	$: if (phase || poll) {
		setupDates();
	}
</script>

<div class={`relative flex flex-col items-center ${Class}`}>
	{#if displayTimelinePhase}
		<div id="poll-timeline" class="text-center dark:text-darkmodeText">
			<span class="font-semibold text-primary dark:text-secondary">
				{$_('Current')}:
			</span>
			{$_('Phase')}
			{currentPhaseIndex + 1}.
			{$_(dateLabels[currentPhaseIndex + 1])}
		</div>
	{/if}

	{#if displayTimeline}
		<div
			class={`m-4 flex justify-between rounded-md
				${horizontal ? '' : 'gap-20'}
				${horizontal ? 'flex-row' : 'flex-col mx-auto'}
				${horizontal ? 'mx-4 w-[calc(100%-4rem)]' : 'm-4'}
				${horizontal ? 'max-h-4' : 'max-w-4'}
			`}
			style={`background: linear-gradient(${
				horizontal ? '90deg' : '180deg'
			}, rgba(189, 208, 255, 1) ${fraction * 100 - 2}%, rgba(191, 191, 191, 1) ${fraction * 100}%`}
		>
			{#each datePlacement as date, i}
				{@const icon =
					i === currentPhaseIndex
						? faCircleExclamation
						: dates[i] <= new Date()
						? faCircleCheck
						: faCircle}

				<HeaderIcon
					Class="!cursor-default"
					size="1x"
					text={`${i + 1}. ${$_(dateLabels[i + 1])}: ${datesArray[i]}`}
					{icon}
				/>
				<!-- color={`${dates[i] <= new Date() ? '#015BC0' : ''}`} -->
			{/each}
		</div>
	{/if}
	{#if enableDetails && displayDetails}
		<button
			class="hover:underline flex items-center gap-1 text-xs"
			on:click={() => (displayDetails = false)}
		>
			<Fa icon={faDownLong} flip />
			{$_('Time details')}
		</button>
		<ul class="p-2">
			{#each dateLabels as label, i}
				{#if i !== 0}
					<li class="border-b md:border-b-0 flex justify-between flex-col md:flex-row text-center">
						<div class="mb-4 md:mb-0">{$_(label)}:</div>
						<div class="mb-4 md:mb-0">{datesArray[i - 1]}</div>
					</li>
				{/if}
			{/each}
		</ul>
	{:else if enableDetails}
		<button
			class="hover:underline flex items-center gap-1 text-xs"
			on:click={() => (displayDetails = true)}
		>
			<Fa icon={faDownLong} />
			{$_('Time details')}
		</button>
	{/if}
</div>

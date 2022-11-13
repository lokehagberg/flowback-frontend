<script lang="ts">
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import { faExclamationCircle } from '@fortawesome/free-solid-svg-icons/faExclamationCircle';
	import { _ } from 'svelte-i18n';

	export let displayDetails = true,
		displayTimeline = true,
		Class = '';
	export let dates: Date[] = [];
	let datesDiaplay: string[] = [];

	let date = new Date();
	// const dateLabels = ["Start", "Proposal end", "Delegate end", "End"]
	const dateLabels = ['Start date', 'End date'];
	const totalTime = dates[dates.length - 1].getTime() - dates[0].getTime();

	// Difference between now and start date
	const toNowTime = date.getTime() - dates[0].getTime();
	let progress = (100 * toNowTime) / totalTime;

	let datePlacement: number[] = [];
	dates.forEach((date, i) => {
		// Date placement on Timeline
		const toDateTime = date.getTime() - dates[0].getTime();
		datePlacement[i] = (100 * toDateTime) / totalTime;

		// Date formating
		datesDiaplay[i] = `${date.getDay()}/${date.getMonth()} ${date.getFullYear()} ${$_('at')} ${
			date.getHours() > 9 ? date.getHours() : `0${date.getHours()}`
		}:${date.getMinutes() > 9 ? date.getMinutes() : `0${date.getMinutes()}`}`;
	});
</script>

<div class={`relative text-black p-4 border border-gray-200 rounded ${Class}`}>
	{#if displayTimeline}
		<h1 class="text-left text-2xl">{$_('Timeline')}</h1>
		{#if import.meta.env.VITE_PROD === 'PROD'}
			<div class="h-6">
				{#each datePlacement as date, i}
					<div class="absolute" style:left={`calc(${date}% - 0.75rem)`}>
						<HeaderIcon
							size="1.5x"
							text={`${$_(dateLabels[i])}: ${datesDiaplay[i]}`}
							icon={faExclamationCircle}
							color={`${dates[i] <= new Date() ? '#015BC0' : ''}`}
						/>
					</div>
				{/each}
			</div>
		{/if}
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
					<div class="mb-4 md:mb-0">{datesDiaplay[i]} CET</div>
				</li>
			{/each}
		</ul>
	{/if}
</div>

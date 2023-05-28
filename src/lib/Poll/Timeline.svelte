<script lang="ts">
	import { formatDate } from '$lib/Generic/DateFormatter';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import { faSquareCheck } from '@fortawesome/free-solid-svg-icons/faSquareCheck';
	import { faSquareFull } from '@fortawesome/free-solid-svg-icons/faSquareFull';
	import { faDownLong } from '@fortawesome/free-solid-svg-icons/faDownLong';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';

	export let displayDetails = true,
		displayTimeline = true,
		Class = '';
	export let dates: Date[] = [];
	let datesDisplay: string[] = [];

	let date = new Date();
	// const dateLabels = ["Start", "Proposal end", "Delegate end", "End"]
	const dateLabels = ['Start', 'Proposal end', 'Vote Start', 'Delegate end', 'End'];
	const totalTime = dates[dates.length - 1].getTime() - dates[0].getTime();

	// Difference between now and start date
	const toNowTime = date.getTime() - dates[0].getTime();
	let progress = (100 * toNowTime) / totalTime;

	let datePlacement: number[] = [];
	dates.forEach((date, i) => {
		// Date placement on Timeline
		const toDateTime = date.getTime() - dates[0].getTime();
		datePlacement[i] = (100 * toDateTime) / totalTime;
		datesDisplay[i] = formatDate(date.toString());
	});
	
	onMount(() => {
		console.log(date.getTime() < dates[0].getTime())
	})
</script>

<div class={`relative ${Class}`}>
	{#if displayTimeline}
		<div
			class="flex justify-between mt-2 rounded-md"
			class:none={date.getTime() < dates[0].getTime()}
			class:quarter={date.getTime() < dates[1].getTime() && date.getTime() > dates[0].getTime()}
			class:half={date.getTime() < dates[2].getTime() && date.getTime() > dates[1].getTime()}
			class:three-quarter={date.getTime() < dates[3].getTime() && date.getTime() > dates[2].getTime()}
			class:full={date.getTime() >= dates[4].getTime()}
		>
			{#each datePlacement as date, i}
				<div class="h-6">
					<HeaderIcon
						Class="cursor-default p-0"
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
			class="hover:underline flex items-center gap-1 cursor-pointer text-xs mb-3"
			on:click={() => (displayDetails = true)}
		>
			<Fa icon={faDownLong} />
			{$_('Time details')}
		</ul>
	{/if}
</div>

<style>
	.none {
		background: linear-gradient(90deg, rgba(89, 158, 255, 1) 0%, rgba(191, 191, 191, 1) 0%);
	}

	.quarter {
		background: linear-gradient(90deg, rgba(89, 158, 255, 1) 0%, rgba(191, 191, 191, 1) 15%);
	}

	.half {
		background: linear-gradient(90deg, rgba(89, 158, 255, 1) 25%, rgba(191, 191, 191, 1) 40%);
	}

	.three-quarter {
		background: linear-gradient(90deg, rgba(89, 158, 255, 1) 75%, rgba(191, 191, 191, 1) 75%);
	}

	.full {
		background:rgba(89, 158, 255, 1)
	}
</style>

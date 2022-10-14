<script lang="ts">
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import { faExclamationCircle } from '@fortawesome/free-solid-svg-icons/faExclamationCircle';
	import { _ } from 'svelte-i18n';
	
	export let displayDetails = true;
	export let dates = [
		new Date('2022-09-21'),
		new Date('2022-09-23'),
		new Date('2022-09-25'),
		new Date('2022-09-30')
	];

	let date = new Date();
	// const dateLabels = ["Start", "Proposal end", "Delegate end", "End"]
	const dateLabels = ['Start', 'End'];
	const totalTime = dates[dates.length - 1].getTime() - dates[0].getTime();

	const toNowTime = date.getTime() - dates[0].getTime();
	let progress = (100 * toNowTime) / totalTime;

	let datePlacement: number[] = [];
	dates.forEach((date, i) => {
		const toDateTime = date.getTime() - dates[0].getTime();
		datePlacement[i] = (100 * toDateTime) / totalTime;
	});
</script>

<div class="relative text-black p-4 border border-gray-200 rounded">
	<h1 class="text-left text-2xl">{$_("Timeline")}</h1>
	<div class="h-6">
		{#each datePlacement as date, i}
			<div class="absolute" style:left={`calc(${date}% - 0.75rem)`}>
				<HeaderIcon
					size="1.5x"
					text={`${dateLabels[i]} date: ${dates[i]}`}
					icon={faExclamationCircle}
					color={`${dates[i] <= new Date() ? '#015BC0' : ''}`}
				/>
			</div>
		{/each}
	</div>
	<div class="h-10 mt-10">
		<div class={`absolute bg-gray-300 left-0 h-6 rounded-full w-full`} />
		<div
			class={`absolute bg-blue-400 left-0 h-6 rounded-full`}
			style:width={`${progress < 100 ? progress : 100}%`}
		/>
	</div>
	{#if displayDetails}
		<div class="border border-gray-200 p-6">
			<ul>
				{#each dateLabels as label, i}
					<li class="flex justify-between flex-col md:flex-row">
						<div class="mb-4">{label} {$_("date")}:</div>
						<div class="mb-4">{dates[i]}</div>
					</li>
				{/each}
			</ul>
		</div>
	{/if}
</div>

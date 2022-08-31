<script lang="ts">
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';

	let dates = [new Date('2022-08-24'), new Date('2022-08-25'), new Date('2022-09-03')];
	let date = new Date();

	const totalTime = dates[dates.length - 1].getTime() - dates[0].getTime();

	const toNowTime = date.getTime() - dates[0].getTime();
	let progress = (100 * toNowTime) / totalTime;

	let datePlacement: number[] = [];
	dates.forEach((date, i) => {
		const toDateTime = date.getTime() - dates[0].getTime();
		datePlacement[i] = (100 * toDateTime) / totalTime;
	});
</script>

<div class="relative mt-6">
	<h1 class="text-left text-2xl">Timeline</h1>
	<div class="h-6">
		{#each datePlacement as date, i}
			<div class="absolute" style:left={`calc(${date}% - 0.75rem)`}>
				<HeaderIcon text={`${dates[i]}`} />
			</div>
		{/each}
	</div>
	<div class="h-10 mt-2">
		<div class={`absolute bg-gray-300 left-0 h-6 rounded-full w-full`} />
		<div
			class={`absolute bg-blue-400 left-0 h-6 rounded-full`}
			style:width={`${progress < 100 ? progress : 100}%`}
		/>
	</div>
</div>

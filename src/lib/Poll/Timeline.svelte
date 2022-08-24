<script lang="ts">
	let dates = [new Date('2022-08-24'), new Date('2022-08-25'), new Date('2022-08-30')];
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

<div class="relative">
	<div class="h-6">
		{#each datePlacement as date}
			<div class="absolute bg-gray-400 h-6 w-6 rounded-full" style:left={`calc(${date}% - 0.75rem)`} />
		{/each}
	</div>
	<div class="h-10">
		<div class={`absolute bg-gray-300 left-0 h-6 rounded-full w-full`} />
		<div class={`absolute bg-blue-400 left-0 h-6 rounded-full`} style:width={`${progress}%`} />
	</div>
</div>

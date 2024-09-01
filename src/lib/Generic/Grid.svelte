<script lang="ts">
	export let x = 10,
		y = 10;
	// w = 200,
	// h = 300;
</script>

<div
	class="grid"
	style={`grid-template-columns: repeat(${x}, 1fr); grid-template-rows: repeat(${y}, 1fr);`}
>
	{#each { length: y } as _, j}
		{#each { length: x } as _, i}
			<div class="border p-4">
				<slot {i} {j} />
			</div>
		{/each}
	{/each}
</div>

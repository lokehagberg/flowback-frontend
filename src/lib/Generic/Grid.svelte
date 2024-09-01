<script lang="ts">
	import { faCheck } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';

	export let x = 10,
		y = 10;
	// w = 200,
	// h = 300;

	let clicked = [[1, 1]];
</script>

<div
	class="grid"
	style={`grid-template-columns: repeat(${x}, 1fr); grid-template-rows: repeat(${y}, 1fr);`}
>
	{#each { length: y } as _, j}
		{#each { length: x } as _, i}
			<div
				class="border p-4"
				on:click={() => {
					clicked.filter((pos) => pos[0] === i && pos[1] === j);
					clicked.push([i, j]);
                    clicked = clicked
				}}
				on:keydown
				role="button"
				tabindex="0"
			>
				{#if clicked.find((pos) => pos[0] === i && pos[1] === j)}
					<div class="bg-green-600 p-6"><Fa icon={faCheck} color="white" /></div>
				{:else}
					<slot {i} {j} />
				{/if}
			</div>
		{/each}
	{/each}
</div>

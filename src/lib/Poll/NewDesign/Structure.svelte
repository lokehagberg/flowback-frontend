<script lang="ts">
	import { onMount } from 'svelte';
	import type { poll } from '../interface';
	import Timeline from './Timeline.svelte';

	export let poll: poll, Class = ""

	let genericStyle = 'bg-white p-6 h-[100%] overflow-y-scroll h-full';
	onMount(() => {});
</script>

{#if poll}
	<div class={`${Class} poll-grid p-12 max-w-[1200px] w-full gap-4 lg:gap-6`}>
		<Timeline displayDetails={false} bind:poll pollType={4} Class="timeline-grid" />

		{#if $$slots.left}
			<div class={`${genericStyle}`}>
				<slot name="left" />
			</div>
		{/if}

		{#if $$slots.right}
			<div class={`${genericStyle}`}>
				<slot name="right" />
			</div>
		{/if}

		{#if $$slots.bottom}
			<div class={`${genericStyle} bottom-grid`}>
				<slot name="bottom" />
			</div>
		{/if}
	</div>
{/if}

<style>
	.poll-grid {
		grid-template-columns: 0.1fr 1fr 1fr;
		grid-template-rows: 80vh 80vh;
		display: grid;
	}

	.timeline-grid {
		grid-area: 1 / 1 / 3 / 1;
	}

	.bottom-grid {
		grid-area: 2 / 2 / 2 / 4;
	}
</style>

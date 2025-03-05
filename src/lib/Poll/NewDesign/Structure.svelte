<script lang="ts">
	import { onMount } from 'svelte';
	import type { Phase, poll } from '../interface';
	import Timeline from './Timeline.svelte';

	export let poll: poll | null = null,
		Class = '',
		phase: Phase = 'area_vote';

	let genericStyle =
		'bg-white dark:bg-darkobject dark:text-darkmodeText p-4 h-[100%] h-full rounded shadow-md';

	onMount(() => {});
</script>

<div
	class={`${Class} ${
		poll ? 'poll-grid' : 'poll-grid-no-timeline'
	} p-12 max-w-[1200px] w-full gap-4 lg:gap-6`}
>
	{#if poll}
		<Timeline
			bind:phase
			bind:poll
			displayDetails={false}
			pollType={4}
			Class={'!absolute md:!relative left-4 md:left-0'}
		/>
	{/if}

	{#if $$slots.left}
		<div class={`${genericStyle}  `}>
			<slot name="left" />
		</div>
	{/if}

	{#if $$slots.right}
		<div class={`${genericStyle}  overflow-auto`}>
			<slot name="right" />
		</div>
	{/if}

	{#if $$slots.bottom}
		<div class={`${genericStyle} overflow-auto bottom-grid`}>
			<slot name="bottom" />
		</div>
	{/if}
</div>

<style>
	@media (min-width: 768px) {
		.poll-grid {
			grid-template-columns: 0.1fr 1fr 1fr;
			display: grid;
		}

		.poll-grid-no-timeline {
			grid-template-columns: 0.1fr 1fr;
			display: grid;
		}

		.timeline-grid {
			grid-area: 1 / 1 / 3 / 1;
		}

		.bottom-grid {
			grid-area: 2 / 2 / 2 / 4;
		}
	}
</style>

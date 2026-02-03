<script lang="ts">
	import { onMount } from 'svelte';
	import type { Phase, poll } from '../interface';
	import Timeline from './Timeline.svelte';
	import { isMobile } from '$lib/utils/isMobile';

	export let poll: poll | null = null,
		Class = '',
		phase: Phase = 'area_vote',
		resetScroll = false,
		showRight = false,
		showBoth = false;

	// 'bg-white h-[490px] max-h-[490px] dark:bg-darkobject dark:text-darkmodeText p-4 rounded shadow-md',
	let genericStyle =
			'h-full overflow-y-auto bg-white dark:bg-darkobject dark:text-darkmodeText p-4 rounded shadow-md',
		right: HTMLDivElement | null = null;

	$: if (resetScroll) {
		right?.children[0].scrollTo(0, 0);
		right?.scrollTo(0, 0);
		resetScroll = false;
	}

	$: gridClass = `
		${Class} 
		${poll ? 'poll-grid' : 'poll-grid-no-timeline'} 
		p-3 md:p-6 lg:p-12 max-w-[1200px] w-full gap-4 lg:gap-6 
		${$isMobile ? 'flex flex-col' : 'grid'}
	`;

	$: showLeftSlot = $$slots.left && (!$isMobile || !showRight || showBoth);

	$: showRightSlot =
		$$slots.right && ($isMobile ? showRight || showBoth : true);

	$: showBottomSlot = $$slots.bottom;
</script>

<div class={gridClass} id="poll-structure">
	{#if poll}
		<Timeline
			bind:phase
			bind:poll
			enableDetails={false}
			Class={$isMobile
				? 'w-full mobile-timeline'
				: 'desktop-timeline h-[490px]'}
			horizontal={$isMobile}
		/>
	{/if}

	{#if showLeftSlot}
		<div class={genericStyle}>
			<slot name="left" class="h-full" />
		</div>
	{/if}

	{#if showRightSlot}
		<div bind:this={right} class={genericStyle}>
			<slot name="right" class="h-full" />
		</div>
	{/if}

	{#if showBottomSlot}
		<div class={`${genericStyle} overflow-auto bottom-grid h-fit`}>
			<slot name="bottom" />
		</div>
	{/if}
</div>

<style>
	@media (min-width: 768px) {
		.poll-grid {
			grid-template-columns: 0.1fr repeat(2, minmax(0, 1fr));
			grid-template-rows: repeat(2, minmax(0, 55vh));
			display: grid;
			max-height: 2000px;
		}

		.poll-grid-no-timeline {
			grid-template-columns: 1fr 1fr;
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

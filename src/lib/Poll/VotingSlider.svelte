<script lang="ts">
	import Button from '$lib/Generic/Button.svelte';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	export let onSelection = (pos: number | null) => {},
		lineWidth = 0,
		score: number | null = null,
		isVoting, // Add this new prop
		delegateScore: number | null = null;

	const maxScore = 5;
	const snapPoints = Array.from({ length: maxScore + 1 }, (_, i) => i); // [0,1,2,3,4,5]

	let dragLinePosition: number | null = null;
	let currentSnapPosition: number | null = null;

	const snapToSnapPoint = (value: number) => {
		const nearestSnap = snapPoints.reduce((prev, curr) =>
			Math.abs(curr - value) < Math.abs(prev - value) ? curr : prev
		);

		lineWidth = (nearestSnap / maxScore) * 100;
		currentSnapPosition = nearestSnap;
		return nearestSnap;
	};

	const onMouseDown = (event: MouseEvent) => {
		const container = (event.target as HTMLElement).closest('#track-container') as HTMLElement;
		if (!container) return;

		const onMouseMove = (e: MouseEvent) => {
			const rect = container.getBoundingClientRect();
			const offsetX = e.clientX - rect.left;
			const width = (offsetX / rect.width) * 100;
			const value = (width / 100) * maxScore;

			dragLinePosition = offsetX;
			score = snapToSnapPoint(value);
		};

		const onMouseUp = () => {
			onSelection(currentSnapPosition!);
			document.removeEventListener('mousemove', onMouseMove);
			document.removeEventListener('mouseup', onMouseUp);
			dragLinePosition = null;
		};

		document.addEventListener('mousemove', onMouseMove);
		document.addEventListener('mouseup', onMouseUp);
	};

	$: score !== null ? snapToSnapPoint(score) : snapToSnapPoint(0);
	$: isOverridden = delegateScore !== null && score !== null && score !== delegateScore;
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	class="w-full bg-white dark:bg-darkobject py-3 px-1 rounded-lg draggable relative"
	on:mousedown={onMouseDown}
	style="background-color: {isOverridden ? '#fbcfe8' : '#e5e7eb'};"
>
	<div id="track-container" class="p-1 relative w-full h-3 bg-purple-200 rounded-full">
		<!-- Active bar -->
		<div
			class="absolute top-0 left-0 h-full"
			style="width: {lineWidth}%; background-color: {isOverridden ? '#ec4899' : '#a78bfa'};"
		/>

		{#each snapPoints as point, index}
			<div
				class="absolute top-1/2 w-2 h-2 bg-white rounded-full border border-gray-400 -translate-y-1/2"
				style="left: {index === 0
					? '2px'
					: index === snapPoints.length - 1
					? 'calc(100% - 2px)'
					: (point / maxScore) * 100 + '%'}; transform: {index === 0
					? 'translateY(-50%)'
					: index === snapPoints.length - 1
					? 'translate(-100%, -50%)'
					: 'translate(-50%, -50%)'}"
			/>
		{/each}

		<!-- Snap indicator line -->
		{#if currentSnapPosition !== null}
			<!-- White rounded background for the line -->
			<div
				class="absolute z-20 w-4 h-8 bg-white rounded-full -translate-x-1/2 top-1/2 -translate-y-1/2"
				style="left: {(currentSnapPosition / maxScore) * 100}%"
			/>
			<!-- Vertical line on top of the background -->
			<div
				class="absolute z-30 w-[1.5px] h-7 bg-gray-900 -translate-x-1/2 top-1/2 -translate-y-1/2"
				style="left: {(currentSnapPosition / maxScore) * 100}%"
			/>

			<!-- Floating value shown only while dragging -->
			{#if dragLinePosition !== null}
				<div
					class="absolute -top-6 z-30 text-sm bg-white px-1 py-0.5 rounded shadow -translate-x-1/2"
					style="left: {(currentSnapPosition / maxScore) * 100}%"
				>
					{#if isVoting}
						{currentSnapPosition}
					{:else}
						{currentSnapPosition * 20}%
					{/if}
				</div>
			{/if}
		{/if}
	</div>
</div>

<div class="flex justify-center w-full">
	<Button
		Class="!p-0 border-none text-sm text-red-600 !bg-transparent cursor-pointer hover:underline hover:bg-transparent"
		buttonStyle="warning-light"
		onClick={() => {
			lineWidth = 0;
			score = null;
			currentSnapPosition = null;
			onSelection(null);
		}}
	>
		{$_(isVoting ? 'Clear vote' : 'Clear probability')}
	</Button>
</div>

<style>
	.draggable {
		cursor: grab;
	}
	.draggable:active {
		cursor: grabbing;
	}
</style>

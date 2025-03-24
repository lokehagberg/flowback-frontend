<script lang="ts">
	import { onMount } from 'svelte';
	export let onSelection = (pos: number) => {},
		lineWidth = 0,
		score: number | null = null;

	let snapPoints = [0, 20, 40, 50, 60, 80, 100],
		dragLinePosition: any = null,
		currentSnapPosition: any;

	const snapToSnapPoint = (width: number) => {
		const nearestSnap = snapPoints.reduce((prev, curr) =>
			Math.abs(curr - width) < Math.abs(prev - width) ? curr : prev
		);

		lineWidth = nearestSnap;
		currentSnapPosition = nearestSnap;
		return nearestSnap;
	};

	const onMouseDown = (event: any) => {
		const container = event.target.parentElement;

		const onMouseMove = (e: any) => {
			const rect = container.getBoundingClientRect();
			const offsetX = e.clientX - rect.left;
			const width = (offsetX / rect.width) * 100;

			dragLinePosition = offsetX;
			snapToSnapPoint(width);
		};

		const onMouseUp = () => {
			onSelection(currentSnapPosition / 20);
			document.removeEventListener('mousemove', onMouseMove);
			document.removeEventListener('mouseup', onMouseUp);
			dragLinePosition = null; // Hide the vertical line after mouse up
		};

		document.addEventListener('mousemove', onMouseMove);
		document.addEventListener('mouseup', onMouseUp);
	};

	// To ensure the snapping points align visually
	let snapPointsInPixels: any[] = [];
	onMount(() => {
		const container = document.getElementById('track-container');
		const rect = container?.getBoundingClientRect();
		if (rect) snapPointsInPixels = snapPoints.map((point) => (rect.width * point) / 100);
	});

	$: if (score !== null) snapToSnapPoint(score * 20);
	// $: if (score !== null) console.log(score, 'score');
	$: if (score === null) score = 2.5
	

	// $: console.log(score, dragLinePosition, currentSnapPosition, lineWidth);
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	class="w-full bg-white dark:bg-darkobject pt-1 pb-3 p-1 rounded-lg draggable relative"
	on:mousedown={onMouseDown}
>
	<div id="track-container" class="relative w-full h-2 bg-purple-200 rounded-full">
		{#if dragLinePosition !== null}
			<div
				class="absolute top-0 left-0 h-[40px<] border-l-2 border-gray-600 w-[40px]"
				style="left: {dragLinePosition}px;"
			/>
		{/if}
		<div
			class="absolute top-0 left-0 h-full bg-purple-500 rounded-full"
			style="width: {lineWidth}%;"
		/>

		<!-- {#each snapPointsInPixels as point (point)}
			<div class="absolute top-0 h-full w-1 bg-gray-400 opacity-50" style="left: {point}px;" />
		{/each} -->
	</div>
	<div
		class={`absolute -top-[20%] ${
			// This is stupid, but Tailwind failed to autogenerate classes when attempting to do left-[${currentSnapPosition}%]
			currentSnapPosition === null
				? 'left-[50%]'
				: currentSnapPosition === 0
				? 'left-0'
				: currentSnapPosition === 20
				? 'left-[20%]'
				: currentSnapPosition === 40
				? 'left-[40%]'
				: currentSnapPosition === 50
				? 'left-[50%]'
				: currentSnapPosition === 60
				? 'left-[60%]'
				: currentSnapPosition === 80
				? 'left-[80%]'
				: 'left-[100%]'
		} z-30 bg-white px-0.5 text-sm`}
	>
		|
	</div>
</div>

<style>
	.draggable {
		cursor: grab;
	}
	.draggable:active {
		cursor: grabbing;
	}
</style>

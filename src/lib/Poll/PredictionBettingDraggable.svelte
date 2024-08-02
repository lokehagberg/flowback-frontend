<script lang="ts">
	import { onMount } from 'svelte';
	export let onSelection = (pos: number) => {};

	let lineWidth = 100,
		snapPoints = [0, 20, 40, 60, 80, 100],
		dragLinePosition: any = null,
		width: any,
		currentSnapPosition: any;

	function onMouseDown(event: any) {
		const container = event.target.parentElement;

		function onMouseMove(e: any) {
			const rect = container.getBoundingClientRect();
			const offsetX = e.clientX - rect.left;
			const width = (offsetX / rect.width) * 100;

			dragLinePosition = offsetX;

			// Snap to nearest point and update currentSnapPosition
			const nearestSnap = snapPoints.reduce((prev, curr) =>
				Math.abs(curr - width) < Math.abs(prev - width) ? curr : prev
			);

			lineWidth = nearestSnap;
			currentSnapPosition = nearestSnap;
		}

		function onMouseUp() {
            console.log(currentSnapPosition, "POH SNAP");
            
			onSelection(currentSnapPosition  / 20);
			document.removeEventListener('mousemove', onMouseMove);
			document.removeEventListener('mouseup', onMouseUp);
			dragLinePosition = null; // Hide the vertical line after mouse up
		}

		document.addEventListener('mousemove', onMouseMove);
		document.addEventListener('mouseup', onMouseUp);
	}

	// To ensure the snapping points align visually
	let snapPointsInPixels: any[] = [];
	onMount(() => {
		const container = document.getElementById('track-container');
		const rect = container?.getBoundingClientRect();
		if (rect) snapPointsInPixels = snapPoints.map((point) => (rect.width * point) / 100);
	});
</script>

<div class="w-96 bg-white p-4 rounded-lg shadow-lg">
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	<div
		id="track-container"
		class="relative w-full h-2 bg-purple-200 rounded-full draggable"
		on:mousedown={onMouseDown}
	>
		{#if dragLinePosition !== null}
			<div
				class="absolute top-0 left-0 h-[40px<] border-l-2 border-gray-600"
				style="left: {dragLinePosition}px;"
			/>
		{/if}
		<div
			class="absolute top-0 left-0 h-full bg-purple-500 rounded-full"
			style="width: {lineWidth}%;"
		/>

		{#each snapPointsInPixels as point (point)}
			<div class="absolute top-0 h-full w-1 bg-gray-400 opacity-50" style="left: {point}px;" />
		{/each}
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

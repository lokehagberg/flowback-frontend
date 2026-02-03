<script lang="ts">
	import Button from '$lib/Generic/Button.svelte';
	import { _ } from 'svelte-i18n';
	import { groupUserStore } from '$lib/Group/interface';
	import type { Phase } from './interface';

	export let onSelection = (pos: number | null) => {},
		lineWidth = 0,
		score: number | null = null,
		phase: Phase,
		disabled = false,
		style: 'purple' | 'gray' = 'purple',
		maxScore = 5,
		dragLinePosition: number | null = null,
		currentSnapPosition: number | null = null,
		id = '';

	const snapPoints = Array.from({ length: maxScore + 1 }, (_, i) => i); // [0,1,2,3,4,5]

	const snapToSnapPoint = (value: number) => {
		const nearestSnap = snapPoints.reduce((prev, curr) =>
			Math.abs(curr - value) < Math.abs(prev - value) ? curr : prev
		);

		lineWidth = (nearestSnap / maxScore) * 100;
		currentSnapPosition = nearestSnap;
		return nearestSnap;
	};

	const onMouseDown = (e: MouseEvent) => {
		const onMouseMove = (e: MouseEvent) => {
			const container = (e.target as HTMLElement).closest(`#track-container-${id}`) as HTMLElement;
			if (!container) return;

			const rect = container.getBoundingClientRect();
			const offsetX = e.clientX - rect.left;
			const width = (offsetX / rect.width) * 100;
			const value = (width / 100) * maxScore;

			dragLinePosition = offsetX;
			score = snapToSnapPoint(value);
		};

		const onMouseUp = () => {
			if (disabled) return;
			onSelection(currentSnapPosition!);
			document.removeEventListener('mousemove', onMouseMove);
			document.removeEventListener('mouseup', onMouseUp);
			dragLinePosition = null;
		};

		onMouseMove(e);
		document.addEventListener('mousemove', onMouseMove);
		document.addEventListener('mouseup', onMouseUp);
	};

	$: score !== null ? snapToSnapPoint(score) : snapToSnapPoint(0);
	// $: isOverridden = delegateScore !== null && score !== null && score !== delegateScore;
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	class="w-full bg-white dark:bg-darkobject rounded-lg relative disabled"
	class:opacity-50={disabled}
	class:draggable={!disabled &&
		(($groupUserStore?.delegate_pool_id && phase === 'delegate_vote') ||
			(!$groupUserStore?.delegate_pool_id && phase === 'vote'))}
	on:mousedown={(e) => {
		if (!disabled) onMouseDown(e);
	}}
	class:cursor-grab={!disabled}
	class:cursor-not-allowed={disabled}
>
	<div
		id={`track-container-${id}`}
		style={`color: ${style}`}
		class="{disabled ? 'disabled' : ''} relative w-full h-3 bg-purple-200 rounded-full"
	>
		<!-- Active bar -->
		<div
			class="absolute top-0 left-0 h-full"
			class:!dark:bg-gray-500={style === 'gray' || disabled}
			class:!bg-gray-300={style === 'gray' || disabled}
			style="width: {lineWidth}%; background-color: {true ? '#a78bfa' : '#BBBBBB'};"
		/>

		{#each snapPoints as point, index}
			<!-- on:click={() => {
					if (disabled) return;
					lineWidth = (point / maxScore) * 100;
					currentSnapPosition = point;
					onSelection(point);
				}} -->
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
					class="dark:text-black absolute -top-6 z-30 text-sm bg-white px-1 py-0.5 rounded shadow -translate-x-1/2"
					style="left: {(currentSnapPosition / maxScore) * 100}%"
				>
					{#if phase === 'prediction_bet'}
						{currentSnapPosition * 20}%
					{:else}
						{currentSnapPosition}
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
			if (disabled) return;
			lineWidth = 0;
			score = null;
			currentSnapPosition = null;
			onSelection(null);
		}}
		{disabled}
	>
		{#if !disabled}
			{$_(phase === 'prediction_bet' ? 'Clear probability' : 'Clear vote')}
		{/if}
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

<script lang="ts">
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faCheckCircle, faTimesCircle } from '@fortawesome/free-solid-svg-icons';
	import type { poppup } from './interfaces';
	import { writable } from 'svelte/store';

	// Store to manage queue of popup messages
	const popupQueue = writable<(poppup & { id: number })[]>([]);
	let popupId = 0; // Unique ID for each popup

	// Function to add new popup to queue
	export function addPopup(popup: poppup) {
		const id = popupId++; // Increment ID immediately

		if ($popupQueue.length >= 5) {
			// If queue is full, remove the oldest popup
			popupQueue.update((queue) => queue.slice(1));
		}

		popupQueue.update((queue) => {
			const newPopup = { ...popup, show: false, id };
			return [...queue, newPopup];
		});

		// Trigger animation for the new popup
		setTimeout(() => {
			popupQueue.update((queue) => {
				const newQueue = [...queue];
				const index = newQueue.findIndex((p) => p.id === id);
				if (index === -1) {
					console.warn('Popup not found for ID:', id); // Debug log
					return queue;
				}
				newQueue[index].show = true;
				return newQueue;
			});

			// Remove popup after display duration
			setTimeout(() => {
				popupQueue.update((queue) => {
					const newQueue = [...queue];
					const index = newQueue.findIndex((p) => p.id === id);
					if (index === -1) {
						console.warn('Popup not found for removal, ID:', id); // Debug log
						return queue;
					}
					newQueue[index].show = false;
					// Remove after transition
					setTimeout(() => {
						popupQueue.update((q) => {
							const newQueue = q.filter((p) => p.id !== id);
							// console.log('Removed popup with ID:', id, 'New queue:', newQueue); // Debug log
							return newQueue;
						});
					}, 300); // Transition duration
					return newQueue;
				});
			}, 7000); // Display duration
		}, 100); // Increased delay to ensure DOM updates
	}

	// Debug queue changes
	// $: console.log('Current popupQueue:', $popupQueue);
</script>

{#each $popupQueue as popup (popup.id)}
	<div
		id="popup-{popup.id}"
		class="bg-white dark:bg-darkobject dark:text-darkmodeText fixed right-5 z-50 shadow-xl flex gap-2 items-center px-4 py-2 rounded-md opacity-0 transition-all duration-300"
		style="bottom: {1 + $popupQueue.indexOf(popup) * 3.5}rem;"
		class:show={popup.show}
		hidden={!popup.show}
	>
		<Fa
			icon={popup.success ? faCheckCircle : faTimesCircle}
			color={popup.success ? 'green' : 'red'}
		/>
		<span>{$_(popup.message)}</span>
	</div>
{/each}

<style>
	.show {
		opacity: 1 !important;
		transform: translateY(0) !important;
	}
</style>

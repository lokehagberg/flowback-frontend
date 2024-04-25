<!-- TODO: Make the design nicer and larger, make it draggable, add more options -->

<script lang="ts">
	import { onDestroy, onMount } from 'svelte';
	import CrossButton from './CrossButton.svelte';
	import { numberOfModalOpen } from './Modal';

	export let open = false,
		Class = '',
		onClose = () => {},
		onSubmit = () => {};

	let myVal = 0;

	$: if (open) {
		numberOfModalOpen.update((val) => val + 1);
		numberOfModalOpen.subscribe(val => myVal = val)
	} 
	else {
		numberOfModalOpen.update((val) => val - 1);
		numberOfModalOpen.subscribe(val => myVal = val)
	} 

	$: if (!open) onClose();
</script>

<div
	class:hidden={!open}
	id="popup-modal"
	tabindex="-1"
	class={`bg-transparent overflow-y-auto overflow-x-hidden fixed left-1/2 -translate-x-1/2 top-1/2 -translate-y-1/2 z-${50} h-modal ${Class}`}
>
	<div
		class="dark:bg-darkbackground dark:text-darkmodeText shadow-xl border border-gray-300 rounded bg-white relative p-4 w-full max-w-md h-full"
	>
		<div class="text-xl border-b-2 border-gray-300 border-solid">
			<slot name="header" />
			<CrossButton action={() => (open = false)} />
		</div>
		{#if onSubmit !== (() => {})}
			<form on:submit={onSubmit}>
				<div class="p-6 text-center">
					<slot name="body" />
				</div>
				<slot name="footer" />
			</form>
		{:else}
			<div class="p-6 text-center">
				<slot name="body" />
			</div>
			<slot name="footer" />
		{/if}
	</div>
</div>

<!-- TODO: Make the design nicer and larger, make it draggable, add more options -->

<script lang="ts">
	import CrossButton from './CrossButton.svelte';

	export let open = false,
		Class = '',
		onClose = () => {},
		onSubmit = () => {};
	$: if (!open) onClose();
	$: console.log(open);
</script>

<div id="overlay" class="overlay" class:hidden={!open}>
	<div
		id="popup-modal"
		tabindex="-1"
		class={`bg-transparent overflow-y-auto overflow-x-hidden fixed left-1/2 -translate-x-1/2 top-1/2 -translate-y-1/2 z-50 h-modal ${Class}`}
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
</div>

<style>
	.overlay {
		position: fixed; /* Positioning and size */
		top: 0;
		left: 0;
		width: 100vw;
		height: 100vh;
		background-color: rgba(128, 128, 128, 0.5); /* color */
		z-index: 49;
	}
</style>

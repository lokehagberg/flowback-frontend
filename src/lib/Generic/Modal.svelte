<script lang="ts">
	import CrossButton from './CrossButton.svelte';
	//TODO: Make the design nicer and larger, make it draggable, add more options

	export let open = false,
		Class = '',
		onOpen = () => {},
		onClose = () => {},
		onSubmit = () => {};

	const closeModal = (event: MouseEvent) => {
		event.stopPropagation();
		open = false;
	};

	const stopPropagation = (event: MouseEvent) => {
		event.stopPropagation();
		onCloseModal();
	};

	const hideScrollbar = (hide: boolean) => {
		const html = document.querySelector('html');
		if (!html) return;

		html.style.overflowY = hide ? 'hidden' : 'visible';
	};

	const onOpenModal = () => {
		hideScrollbar(true);
		onOpen();
	};

	const onCloseModal = () => {
		hideScrollbar(false);
		onClose();
	};

	$: if (open) onOpenModal();
</script>

<div
	id="overlay"
	class="overlay"
	class:hidden={!open}
	on:click={closeModal}
	tabindex="0"
	on:keydown
	role="button"
>
	<div
		id="popup-modal"
		tabindex="-1"
		class={`dark:bg-darkbackground bg-white overflow-y-auto overflow-x-hidden border
		border-gray-300 rounded shadow-xl fixed left-1/2 -translate-x-1/2 top-1/2 -translate-y-1/2 z-50 h-modal ${Class}`}
		on:click={stopPropagation}
		on:keydown
		role="button"
	>
		<div class="dark:text-darkmodeText relative p-4 w-full max-w-md h-full">
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

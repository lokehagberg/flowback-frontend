<script lang="ts">
	import Button from './Button.svelte';
	import { _ } from 'svelte-i18n';
	import CrossButton from './CrossButton.svelte';
	import type { ModalButton } from './interfaces';
	//TODO: Make the design nicer and larger, make it draggable, add more options

	export let open = false,
		Class = '',
		onOpen = () => {},
		onClose = () => {},
		onSubmit = () => {},
		buttons: ModalButton[] = [],
		id = 'popup-modal',
		stopAtPropagation = true;

	let modal: HTMLDivElement | undefined, escEvent;

	const closeModal = (event: MouseEvent | KeyboardEvent) => {
		event.stopPropagation();
		open = false;
		hideScrollbar(false);
	};

	const stopPropagation = (event: MouseEvent) => {
		event.stopPropagation();
		if (stopAtPropagation) onCloseModal();
	};

	const hideScrollbar = (hide: boolean) => {
		// document.body.style.overflowY = hide ? 'hidden' : 'scroll';
	};

	const onOpenModal = () => {
		hideScrollbar(true);
		onOpen();
		document.addEventListener('keydown', (e) => {
			if (e.key === 'Escape') {
				closeModal(e);
			}
		});
	};

	const onCloseModal = () => {
		hideScrollbar(false);
		onClose();
	};

	$: if (open) onOpenModal();

	$: if (!open) onClose();
</script>

<div
	id="overlay"
	class="overlay"
	class:hidden={!open}
	on:click={closeModal}
	tabindex="-1"
	on:keydown
	role="button"
>
	<div
		{id}
		class={`w-[80%] !cursor-default max-h-[80vh] mt-10 dark:bg-darkbackground bg-white overflow-y-auto overflow-x-hidden border
		border-gray-300 rounded shadow-xl fixed left-1/2 -translate-x-1/2 top-1/2 -translate-y-1/2 z-50 max-w-[400px] ${Class}`}
		on:click={stopPropagation}
		tabindex="0"
		on:keydown
		role="button"
		bind:this={modal}
	>
		<div class="dark:text-darkmodeText relative p-4 w-full h-full">
			<!-- <div class="text-xl border-b-2 border-gray-300 border-solid  break-word"> -->
			<div class="text-xl break-word">
				<slot name="header" />
				<CrossButton action={() => (open = false)} />
			</div>
			{#if onSubmit !== (() => {})}
				<form on:submit|preventDefault={onSubmit}>
					<div class="p-6 text-center break-word">
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
			<div class="flex justify-center gap-2">
				{#each buttons as button}
					<Button
						id={button.label}
						buttonStyle={button.type}
						Class={`flex-1 ${button.class || ''}`}
						onClick={button.onClick}
					>
						{$_(button.label)}
					</Button>
				{/each}
			</div>
		</div>
	</div>
</div>

<style>
	.overlay {
		position: fixed; /* Positioning and size */
		top: 0;
		left: 0;
		width: 100%;
		height: 100vh;
		background-color: rgba(128, 128, 128, 0.5); /* color */
		z-index: 49;
	}
</style>

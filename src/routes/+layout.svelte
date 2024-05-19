<script lang="ts">
	import '../app.css';
	import { initializeLocalization } from '$lib/Localization/i18n';
	import Header from '$lib/Header/Header.svelte';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	initializeLocalization();
	export const prerender = true;

	let moved = false;

	onMount(() => {
		const handlePopState = (e: any) => {
			// console.log(e);
			// const newPage = location.href;
			// goto(newPage);
		};

		window.addEventListener('popstate', handlePopState);
	});
</script>

<main class="h-[100wh]">
	<Header />
	<slot />
</main>

<!-- <style lang="postcss">
	:global(body) {
		@apply bg-darkbackground;
	}
</style> -->

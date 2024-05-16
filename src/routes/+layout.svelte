<script lang="ts">
	import '../app.css';
	import { initializeLocalization } from '$lib/Localization/i18n';
	import Header from '$lib/Header/Header.svelte';

	initializeLocalization();
	export const prerender = true;
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

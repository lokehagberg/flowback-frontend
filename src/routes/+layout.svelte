<script lang="ts">
	import '../app.css';
	import { initializeLocalization } from '$lib/Localization/i18n';
	import Header from '$lib/Header/Header.svelte';
	import { onNavigate } from '$app/navigation';

	initializeLocalization();
	export const prerender = true;

	onNavigate(() => {
		console.log("Is this chat?")
	})
</script>

<main class="h-[100wh]">
	<Header />
	<slot />
</main>
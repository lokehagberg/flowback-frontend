<script>
	import Chat from '$lib/Chat/Chat.svelte';
	import Header from '$lib/Header/Header.svelte';
	import { onMount } from 'svelte';
	import Cookies from './Cookies.svelte';
	import { TriggerDarkMode } from './DarkMode';
	export let centered = false;

	onMount(() => {
		let backed = false;
		TriggerDarkMode();
		// Odd solution to move back in history twice, since one has to doubble click otherwise
		window.onpopstate = (e) => {
			if (!backed) history.back();
			backed = true;
		};
	});
</script>

<Header />

<!-- <Chat /> -->

<div class={`${centered ? 'flex justify-center flex-col items-center' : ''}`}>
	<slot />
</div>
<Cookies />

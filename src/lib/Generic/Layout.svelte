<script>
	import Chat from '$lib/Chat/Chat.svelte';
	import Header from '$lib/Header/Header.svelte';
	import { onMount } from 'svelte';
	import Cookies from './Cookies.svelte';
	import { TriggerDarkMode } from './DarkMode';
	export let centering = false;

	onMount(() => {
		TriggerDarkMode();
	});
</script>

<Header />

<Chat />

<div class={`${centering ? 'flex justify-center flex-col items-center' : ''}`}>
	<slot />
</div>
<Cookies />

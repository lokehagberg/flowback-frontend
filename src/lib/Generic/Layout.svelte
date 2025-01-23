<script>
	import { onMount } from 'svelte';
	import Cookies from './Cookies.svelte';
	import { TriggerDarkMode } from './DarkMode';
	export let centered = false, Class = ""

	onMount(() => {
		TriggerDarkMode();
	});
</script>

<div class={`${centered ? 'flex justify-center flex-col items-center' : ''} ${Class}`}>
	<slot />
</div>
<Cookies />

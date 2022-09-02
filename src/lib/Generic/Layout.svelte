<script>
	import Header from '$lib/Header/Header.svelte';

	export let centering = false;
</script>

<Header />
<div class={`${centering ? "flex justify-center flex-col items-stretch" : ""}`}>
	<slot />
</div>
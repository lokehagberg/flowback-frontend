<script>
	import Header from '$lib/Header/Header.svelte';

	export let centering = false;
</script>

<Header />
<div class={`positioning ${centering ? "flex justify-center flex-col items-stretch" : ""}`}>
	<slot />
</div>

<style>
	.positioning {
		/* 2 rem from the padding
    on the header, 40px from the height of each symbol/the logo on the header */
		margin-top: 68px;
	}
</style>

<script>
	import Header from '$lib/Header/Header.svelte';
</script>

<Header />
<div class="positioning">
	<slot />
</div>

<style>
	.positioning {
		/* 2 rem from the padding
    on the header, 40px from the height of each symbol/the logo on the header */
		margin-top: 68px;
	}
</style>

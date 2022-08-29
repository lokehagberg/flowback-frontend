<script>
	import Header from '$lib/Header/Header.svelte';
</script>

<Header />
<div class="positioning">
	<slot />
</div>

<style>
	.positioning {
		margin-top: calc(2rem + 40px);
	}
</style>

<script>
	import Layout from '$lib/Generic/Layout.svelte';
	import { onMount } from 'svelte';

	let display404 = false;
	// Scuffed solution on 404 page flashing
	// TODO: Solve this with a Svelte 5 migration and Server Side Rendering
	onMount(() => {
		setTimeout(() => {
			display404 = true
		}, 3000);
	})

</script>

<Layout>
	{#if display404}
	<h1 class="dark:text-darkmodeText">404 not found</h1>
	<div class="text-center dark:text-darkmodeText">No democracy found here</div>
	{/if}
</Layout>

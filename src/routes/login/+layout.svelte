<script lang="ts">
	import { onDestroy, onMount } from 'svelte';

	export const prerender = true;

	let mounted = false;

	onMount(() => {
		const header = document.getElementById('header');
		if (!header) return;

		header!.style.display = 'none';
		mounted = true;
	});

	onDestroy(() => {
		if (mounted) {
			const header = document.getElementById('header');
			if (!header) return;

			header!.style.display = 'block';
		}
	});
</script>

<div>
	<slot />
</div>

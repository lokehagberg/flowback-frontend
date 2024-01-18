<script>
	import Layout from '$lib/Generic/Layout.svelte';
	import { test } from '$lib/Blockchain/javascript/test.ts';
	import Button from '$lib/Generic/Button.svelte';
	import { onMount } from 'svelte';

	onMount(() => {
		test();
	})
</script>

<Layout>
	<div class="p-6">
		<Button action={test}>Make Wallet</Button>
	</div>
</Layout>

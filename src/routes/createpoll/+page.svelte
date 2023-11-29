<script lang="ts">
	import Layout from '$lib/Generic/Layout.svelte';
	import CreatePoll from '$lib/Group/Creation/CreatePoll.svelte';
	import { page } from '$app/stores';
	import CreateThread from '$lib/Group/Creation/CreateThread.svelte';
</script>

<svelte:head>
	<title>Creating a Poll</title>
</svelte:head>

<Layout centered>
	{#if $page.url.searchParams.get('type') === 'thread'}
		<CreateThread />
	{:else}
		<CreatePoll />
	{/if}
</Layout>

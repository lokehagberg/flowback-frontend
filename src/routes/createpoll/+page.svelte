<script lang="ts">
	import Layout from '$lib/Generic/Layout.svelte';
	import CreatePoll from '$lib/Group/Creation/CreatePoll.svelte';
	import { _ } from 'svelte-i18n';
</script>

<svelte:head>
	<title>{$_('Creating a Poll')}</title>
</svelte:head>

<Layout centered>
	<CreatePoll />
</Layout>

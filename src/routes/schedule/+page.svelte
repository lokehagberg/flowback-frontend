<script lang="ts">
	import Layout from '$lib/Generic/Layout.svelte';
	import Schedule from '$lib/Schedule/Schedule.svelte';
	import { _ } from 'svelte-i18n';
</script>

<svelte:head>
	<title>Schedule</title>
</svelte:head>

<Layout>
	<div class="relative w-full">
		<Schedule />
	</div>
</Layout>

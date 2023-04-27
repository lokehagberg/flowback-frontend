<script lang="ts">
	import Layout from '$lib/Generic/Layout.svelte';
	import Schedule from '$lib/Schedule/Schedule.svelte';
</script>

<svelte:head>
	<title>Schedule</title>
</svelte:head>

<Layout>
	<Schedule type='user' />
</Layout>

<script lang="ts">
	import { env } from '$env/dynamic/public';
	import { PUBLIC_ONE_GROUP_FLOWBACK } from '$env/static/public';
import Layout from '$lib/Generic/Layout.svelte';
	import Schedule from '$lib/Schedule/Schedule.svelte';
</script>

<svelte:head>
	<title>Schedule</title>
</svelte:head>

<Layout>
	<Schedule type={env.PUBLIC_ONE_GROUP_FLOWBACK ? "group" : "user"}/>
</Layout>

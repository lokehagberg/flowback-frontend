<script>
	import Layout from '$lib/Generic/Layout.svelte';
	import Kanban from '$lib/Group/Kanban.svelte';
	import { _ } from 'svelte-i18n';
</script>

<Layout centering={true}>
	<Kanban type="home" Class="w-[95%] md:w-[80%]"/>
</Layout>

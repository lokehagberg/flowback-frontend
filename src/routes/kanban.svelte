<script>
	import { fetchRequest } from '$lib/FetchRequest';
	import Layout from '$lib/Generic/Layout.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import Kanban from '$lib/Group/Kanban.svelte';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
</script>

<Layout centering={true}>
	<Kanban type="home"/>
</Layout>

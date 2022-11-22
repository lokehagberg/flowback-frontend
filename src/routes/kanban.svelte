<script>
	import { fetchRequest } from '$lib/FetchRequest';
	import Layout from '$lib/Generic/Layout.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	onMount(() => {
		getKanbanEntries();
		// createKanbanEntry();
		updateKanbanEntry();
		// deleteKanbanEntry();
	});

	const createKanbanEntry = async () => {
		const { res, json } = await fetchRequest('POST', 'group/4/kanban/create', {
			assignee: 2,
			description: 'This field is required.',
			tag: 1,
			title: 'I am an impostor'
		});
		statusMessageFormatter(res, json);
	};

	const updateKanbanEntry = async () => {
		const { res, json } = await fetchRequest('POST', 'group/4/kanban/4/update', {
			description: "haiii",
			assignee: 2,
			tag:2,
			title:"No sussy baka"
		});
		statusMessageFormatter(res, json);
	};

	const deleteKanbanEntry = async () => {
		const { res, json } = await fetchRequest('POST', 'group/4/kanban/1/delete', {
			kanban_entry_id:1
		});
		statusMessageFormatter(res, json);
	};

	const getKanbanEntries = async () => {
		const { res, json } = await fetchRequest('GET', 'home/kanban');
		statusMessageFormatter(res, json);
	};
</script>

<Layout centering={true}>
	<div class="bg-white p-6 shadow rounded mt-6">{$_('Under Construction')}</div>
</Layout>

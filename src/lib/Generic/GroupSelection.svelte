<script lang="ts">
	import { _ } from 'svelte-i18n';
	import Select from '$lib/Generic/Select.svelte';
	import { groupStore, workgroupStore } from '$lib/Group/Kanban/Kanban';
	import { onMount } from 'svelte';

	let {
		selectedWorkgroupId = $bindable(null),
		selectedGroupId = $bindable(null),
		disableGroup = false
	}: {
		selectedWorkgroupId: Number | null;
		selectedGroupId: Number | null;
		disableGroup?: boolean;
	} = $props();

	onMount(() => {
		const groupId = Number(new URLSearchParams(location.search).get('groupId'));
		if (groupId !== 0) selectedGroupId = groupId;
	});
</script>

<!-- Select Groups -->
{#if !disableGroup}
	<Select
		disableFirstChoice
		labels={[
			'No Group',
			...$groupStore.filter((g) => g.joined).map((g) => g.name)
		]}
		values={[null, ...$groupStore.filter((g) => g.joined).map((g) => g.id)]}
		bind:value={selectedGroupId}
		label="Group"
		classInner="rounded p-1 border border-gray-300 dark:border-gray-600 bg-white dark:bg-darkobject"
	/>
{/if}

<!-- Select Workgroups -->
<Select
	disableFirstChoice
	labels={[
		'No Workgroup',
		...$workgroupStore
			.filter(
				(w) =>
					w.joined &&
					$groupStore.find(
						(g) => g.id === selectedGroupId && g.joined && g.id === w.group_id
					)
			)
			.map((w) => w.name)
	]}
	values={[
		null,
		...$workgroupStore
			.filter(
				(w) =>
					w.joined &&
					$groupStore.find(
						(g) => g.id === selectedGroupId && g.joined && g.id === w.group_id
					)
			)
			.map((w) => w.id)
	]}
	bind:value={selectedWorkgroupId}
	label="WorkGroup"
	classInner="rounded p-1 border border-gray-300 dark:border-gray-600 bg-white dark:bg-darkobject"
/>

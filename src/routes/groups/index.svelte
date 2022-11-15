<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Layout from '$lib/Generic/Layout.svelte';
	import GroupThumbnail from '$lib/Group/GroupThumbnail.svelte';
	import type { Group } from '$lib/Group/interface';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	let groupList: Group[] = [];

	onMount(() => {
		getGroups();
	});

	const getGroups = async () => {
		const { json } = await fetchRequest('GET', 'group/list?limit=100');
		groupList = json.results.reverse();
	};
</script>

<Layout centering={true}>
	<div class="flex flex-col items-center mt-6 gap-6 mb-6 w-full lg:w-[1100px]">
		{#if import.meta.env.VITE_DISABLE_GROUP_CREATION === 'false' || import.meta.env.VITE_DISABLE_GROUP_CREATION === undefined}
			<a
				href="creategroup"
				class="w-4/5 md:w-1/2 text-center inline bg-blue-600 text-white pl-6 pr-6 md:pl-24 md:pr-24 pt-2 pb-2 rounded cursor-pointer "
				>+ {$_('Create Group')}</a
			>
		{/if}

		{#each groupList as group}
			<GroupThumbnail {group} />
		{/each}
	</div>
</Layout>

<script lang="ts">
	import { getRequest } from '$lib/FetchRequest';
	import Layout from '$lib/Generic/Layout.svelte';
	import GroupThumbnail from '$lib/Group/GroupThumbnail.svelte';
	import { onMount } from 'svelte';
	import type { Group } from './interfaces'

	let groupList: Group[] = [];

	onMount(async () => {
		const response = await getRequest('group/list?limit=100');
		const json = await response.json();
		groupList = json.results;
	});
</script>

<Layout>
	<div class="flex flex-col items-center mt-6 gap-6 mb-6">
		<a
			href="creategroup"
			class="w-1/2 text-center inline bg-blue-600 text-white pl-24 pr-24 pt-2 pb-2 rounded cursor-pointer "
			>+ Create Group</a
		>

		{#each groupList as group}
			<GroupThumbnail {group} />
		{/each}
	</div>
</Layout>

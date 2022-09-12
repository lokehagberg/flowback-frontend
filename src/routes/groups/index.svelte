<script lang="ts">
	import { getRequest } from '$lib/FetchRequest';
	import Layout from '$lib/Generic/Layout.svelte';
	import GroupThumbnail from '$lib/Group/GroupThumbnail.svelte';
	import { onMount } from 'svelte';

	onMount(async () => {
		const res = await getRequest('group/list');
		console.log(res);
	});
</script>

<Layout>
	<div class="flex flex-col items-center mt-6 gap-6 mb-6">
		<a
			href="creategroup"
			class="text-center inline bg-blue-600 text-white pl-24 pr-24 pt-2 pb-2 rounded cursor-pointer "
			>+ Create Group</a
		>
		<GroupThumbnail />
		<GroupThumbnail />
		<GroupThumbnail />
		<GroupThumbnail />
	</div>
</Layout>

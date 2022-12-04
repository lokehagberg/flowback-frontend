<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import Layout from '$lib/Generic/Layout.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import GroupThumbnail from '$lib/Group/GroupThumbnail.svelte';
	import type { Group } from '$lib/Group/interface';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	let groupList: Group[] = [],
		status: StatusMessageInfo;

	onMount(() => {
		getGroups();
	});

	const getGroups = async () => {
		const { res, json } = await fetchRequest('GET', 'group/list?limit=100');
		status = statusMessageFormatter(res, json);
		if (res.ok) groupList = json.results.reverse();
	};
</script>

<svelte:head>
	<title>Flowback Groups</title>
</svelte:head>

<Layout centering={true}>
	<!-- TODO: design of statusmessage is off -->
	<StatusMessage bind:status disableSuccess/>
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

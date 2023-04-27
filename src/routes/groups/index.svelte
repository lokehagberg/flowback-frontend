<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
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
		const { res, json } = await fetchRequest('GET', 'group/list?limit=1000');
		status = statusMessageFormatter(res, json);
		if (res.ok) groupList = json.results.reverse();
	};
</script>

<svelte:head>
	<title>Groups</title>
</svelte:head>

<Layout centering={true}>
	<!-- TODO: design of statusmessage is off -->
	<StatusMessage bind:status disableSuccess/>
	<div class="flex flex-col items-center mt-6 gap-6 mb-6 w-full lg:w-[1300px]">
		{#if import.meta.env.VITE_DISABLE_GROUP_CREATION === 'false' || import.meta.env.VITE_DISABLE_GROUP_CREATION === undefined}
			<Button
				href="creategroup"
				Class= "w-[40%] rounded-2xl"
				>Create Group</Button
			>
		{/if}

		{#each groupList as group}
			<GroupThumbnail {group} />
		{/each}
	</div>
</Layout>

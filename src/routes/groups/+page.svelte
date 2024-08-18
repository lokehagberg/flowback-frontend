<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import Layout from '$lib/Generic/Layout.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import GroupFiltering from '$lib/Group/GroupFiltering.svelte';
	import GroupThumbnail from '$lib/Group/GroupThumbnail.svelte';
	import type { Group } from '$lib/Group/interface';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import { groupMembers as groupMembersLimit } from '$lib/Generic/APILimits.json'
	import {env} from "$env/dynamic/public";

	let groupList: Group[] = [],
		status: StatusMessageInfo,
		filter: any = { joined: 'all', search: '' },
		loading = false;

	onMount(() => {
		getGroups();
	});

	const getGroups = async () => {
		loading = true;
		let urlFilter =
			filter.joined === 'member'
				? '&joined=true'
				: filter.joined === 'not-member'
				? '&joined=false'
				: '';

		urlFilter = `${urlFilter}&name__icontains=${filter.search}`;

		const { res, json } = await fetchRequest('GET', `group/list?limit=${groupMembersLimit}` + urlFilter);
		status = statusMessageFormatter(res, json);

		if (!res.ok) return;

		groupList = json.results
			.reverse()
			.sort((group1: any, group2: any) => +group2.joined - +group1.joined);
		loading = false;
	};
</script>

<svelte:head>
	<title>Groups</title>
</svelte:head>

<Layout centered>
	<!-- TODO: design of statusmessage is off -->
	<Loader bind:loading Class="w-full">
		<StatusMessage bind:status disableSuccess />
		<div class="flex flex-col items-center mt-6 gap-6 mb-6 w-full">
			<!-- {#if env.PUBLIC_DISABLE_GROUP_CREATION === 'FALSE' || env.PUBLIC_DISABLE_GROUP_CREATION === undefined}
				{/if} -->
				<Button href="creategroup" Class="w-[90%] md:w-[40%] rounded-2xl">{$_("Create Group")}</Button>

			<GroupFiltering bind:filter {getGroups} />

			{#each groupList as group}
				<GroupThumbnail {group} />
			{/each}
		</div>
	</Loader>
</Layout>

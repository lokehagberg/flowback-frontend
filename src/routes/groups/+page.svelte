<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import GroupFiltering from '$lib/Group/GroupFiltering.svelte';
	import GroupThumbnail from '$lib/Group/GroupThumbnail.svelte';
	import type { Group, GroupFilter } from '$lib/Group/interface';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import { groups as groupsLimit } from '$lib/Generic/APILimits.json';
	import { env } from '$env/dynamic/public';
	import { goto } from '$app/navigation';
	import { lazyLoading } from '$lib/Generic/GenericFunctions';

	let groupList: Group[] = [],
		filter: GroupFilter = { joined: 'all', search: '' },
		loading = false,
		next: string | undefined | null;

	onMount(() => {
		if (
			env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' &&
			location.href.includes('/groups')
		)
			goto('/home');
		getGroups();
	});

	$: if (filter) {
		next = undefined;
		getGroups();
	}

	const getGroups = async () => {
		// Initially entering group or when searching
		if (next === undefined) {
			let urlFilter = '';

			if (filter.joined === 'member') urlFilter += '&joined=true';
			else if (filter.joined === 'not-member') urlFilter += '&joined=false';

			urlFilter = `${urlFilter}&name__icontains=${filter.search}`;

			loading = true;

			const { res, json } = await fetchRequest(
				'GET',
				`group/list?limit=${groupsLimit}` + urlFilter
			);
			loading = false;

			if (!res.ok) return;

			next = json.next;
			groupList = json?.results;
		}
		// The backend returns next as null when it has reached the end of what can be queried
		// In that case, do nothing
		else if (next === null) return;
		// Lastly, when scrolling, do lazy loading
		else {
			loading = true;
			const { res, json } = await fetchRequest('GET', next);

			loading = false;
			if (!res.ok) return;

			next = json.next;
			groupList = [...groupList, ...json.results];
		}
	};
</script>

<svelte:window onscroll={() => lazyLoading(getGroups)} />

<svelte:head>
	<title>Groups</title>
</svelte:head>

<Layout centered>
	<Loader bind:loading Class="w-full flex flex-col items-center">
		<div
			id="groups-list"
			class="max-w-[1000px] flex flex-col items-center mt-6 gap-6 mb-6 w-full"
		>
			{#if !(env.PUBLIC_DISABLE_GROUP_CREATION === 'TRUE')}
				<Button href="creategroup" Class="w-[90%] md:w-[40%] rounded-2xl"
					>{$_('Create Group')}</Button
				>
			{/if}

			<GroupFiltering bind:filter />

			{#each groupList as group}
				<GroupThumbnail bind:group />
			{/each}
		</div>
	</Loader>
</Layout>

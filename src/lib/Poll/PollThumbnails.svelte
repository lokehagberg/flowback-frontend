<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import PollThumbnail from './PollThumbnail.svelte';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import PollFiltering from './PollFiltering.svelte';
	import type { Filter, poll as Poll } from './interface';
	import Loader from '$lib/Generic/Loader.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { getUserIsOwner } from '$lib/Group/functions';
	import { pollThumbnails as pollThumbnailsLimit } from '../Generic/APILimits.json';
	import Pagination from '$lib/Generic/Pagination.svelte';

	export let Class = '',
		infoToGet: 'group' | 'home' | 'public';

	let polls: Poll[] = [],
		filter: Filter = {
			search: '',
			finishedSelection: 'all',
			public: false,
			order_by: 'start_date_desc',
			tag: null
		},
		loading = false,
		isAdmin = false,
		next = '',
		prev = '';

	const getAPI = async () => {
		let API = '';

		if (infoToGet === 'group') API += `group/${$page.params.groupId}/poll/list?`;
		else if (infoToGet === 'home') API += `home/polls?`;
		//TODO remove public
		else if (infoToGet === 'public') API += `home/polls?public=true`;

		if (filter.order_by) API += `&order_by=${filter.order_by}`;

		// API += `&limit=${pollThumbnailsLimit}`
		API += `&limit=${pollThumbnailsLimit}`;

		if (filter.search.length > 0) API += `&title__icontains=${filter.search}`;

		if (filter.finishedSelection !== 'all')
			API += `&status=${filter.finishedSelection === 'finished' ? '1' : '0'}`;

		// API += '&pinned=false';

		if (filter.tag) API += `&tag_id=${filter.tag}`;

		return API;
	};

	const getPolls = async () => {
		loading = true;
		polls = [];

		const { json, res } = await fetchRequest('GET', await getAPI());

		loading = false;

		if (!res.ok) {
			status = statusMessageFormatter(res, json);
			return;
		}

		polls = json.results;
		next = json.next;
		prev = json.previous;
	};

	let status: StatusMessageInfo;

	onMount(async () => {
		await getPolls();
		//TODO: Part of refactoring with svelte stores includes thsi
		if ($page.params.groupId) isAdmin = await getUserIsOwner($page.params.groupId) || false;
	});
</script>

<div class={`${Class} dark:text-darkmodeText`}>
	<Loader bind:loading>
		<div class={`flex flex-col gap-6 w-full`}>
			<StatusMessage bind:status disableSuccess />
			<PollFiltering
				tagFiltering={infoToGet === 'group'}
				handleSearch={async () => {
					await getPolls();
					// amendWithPinnedPolls();
					return {};
				}}
				bind:filter
			/>
			{#if polls.length === 0 && !loading}
				<div class="bg-white dark:bg-darkobject rounded shadow p-8 mt-6">
					{$_('No polls currently here')}
				</div>
			{:else}
				<!-- <h1 class="text-3xl text-left">Flow</h1> -->
				{#key polls}
					{#if polls.length > 0}
						{#each polls as poll}
							<PollThumbnail {poll} {isAdmin} />
						{/each}
					{:else if !loading}
						<div class="bg-white rounded shadow p-8 dark:bg-darkobject">
							{$_('No polls currently here')}
						</div>
					{/if}
				{/key}
			{/if}
		</div>
		<Pagination
			bind:next
			bind:prev
			bind:iterable={polls}
			Class={'flex gap-2 justify-around w-full mt-6'}
		/>
	</Loader>
</div>

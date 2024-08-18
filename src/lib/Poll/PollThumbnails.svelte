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
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import type { Delegate } from '$lib/Group/interface';

	export let Class = '',
		infoToGet: 'group' | 'home' | 'public' | 'delegate',
		delegate:Delegate = {id:0, pool_id:0, profile_image:"", tags:[], username:""}

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
		prev = '',
		poppup:poppup;

	const getAPI = async () => {
		let API = '';
		// console.log(delegate, {}, delegate === {});

		if (infoToGet === 'group') API += `group/${$page.params.groupId}/poll/list?`;
		//@ts-ignore
		else if (infoToGet === 'delegate') API += `group/poll/pool/${delegate.pool_id}/votes`;
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
			poppup ={message:"Could not get polls", success:false}
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

<Poppup bind:poppup/>
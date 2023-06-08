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

	export let Class = '';
	export let infoToGet: 'group' | 'home' | 'public';

	let polls: Poll[] = [];
	let filter: Filter = {
		search: '',
		finishedSelection: 'all',
		public: false,
		order_by: 'start_date_desc',
		tag: null
	};
	let loading = false,
		isAdmin = false;

	//TODO: Refactor this
	const getPolls = async () => {
		loading = true;

		const finishedFilter =
			filter.finishedSelection === 'all'
				? ''
				: filter.finishedSelection === 'finished'
				? 'finished=true'
				: 'finished=false';

		let API =
			infoToGet === 'group'
				? `group/${$page.params.groupId}/poll/list?limit=100&title__icontains=${
						filter.search || ''
				  }&${finishedFilter}&order_by=${filter.order_by}`
				: infoToGet === 'home'
				? `home/polls?limit=300&title__icontains=${
						filter.search || ''
				  }&${finishedFilter}&order_by=${filter.order_by}`
				: //TODO remove public
				infoToGet === 'public'
				? `home/polls?limit=300&public=true&title__icontains=${
						filter.search || ''
				  }&${finishedFilter}`
				: '';

		API = API + '&pinned=false';

		if (filter.tag) API = API + `&tag=${filter.tag}`;

		const { json, res } = await fetchRequest('GET', API);

		if (!res.ok) status = statusMessageFormatter(res, json);
		else polls = json.results;

		loading = false;
	};

	//TODO: Remove this shit later
	const amendWithPinnedPolls = async () => {
		const finishedFilter =
			filter.finishedSelection === 'all'
				? ''
				: filter.finishedSelection === 'finished'
				? 'finished=true'
				: 'finished=false';

		let API =
			infoToGet === 'group'
				? `group/${$page.params.groupId}/poll/list?limit=100&title__icontains=${
						filter.search || ''
				  }&${finishedFilter}&order_by=${filter.order_by}`
				: infoToGet === 'home'
				? `home/polls?limit=300&title__icontains=${
						filter.search || ''
				  }&${finishedFilter}&order_by=${filter.order_by}`
				: //TODO remove public
				infoToGet === 'public'
				? `home/polls?limit=300&public=true&title__icontains=${
						filter.search || ''
				  }&${finishedFilter}`
				: '';

		API = API + '&pinned=true';

		const { json, res } = await fetchRequest('GET', API);

		if (!res.ok) status = statusMessageFormatter(res, json);
		else polls = [...json.results, ...polls];
	};

	let status: StatusMessageInfo;

	onMount(async () => {
		await getPolls();
		amendWithPinnedPolls();
		if ($page.params.groupId) isAdmin = await getUserIsOwner($page.params.groupId);
	});
</script>

<div class={`${Class} dark:text-darkmodeText`}>
	<Loader bind:loading>
		<div class={`flex flex-col gap-6 w-full`}>
			<StatusMessage bind:status disableSuccess />
			<PollFiltering
				handleSearch={async () => {
					await getPolls();
					amendWithPinnedPolls();
					return {};
				}}
				bind:filter
			/>
			{#if polls.length === 0}
				<div class="bg-white dark:bg-darkobject rounded shadow p-8 mt-6">
					{$_('No polls currently here')}
				</div>
			{:else}
				<!-- <h1 class="text-3xl text-left">Flow</h1> -->

				{#if polls.length > 0}
					{#each polls as poll}
						<PollThumbnail {poll} {isAdmin} />
					{/each}
				{:else}
					<div class="bg-white rounded shadow p-8 dark:bg-darkobject">
						{$_('No polls currently here')}
					</div>
				{/if}
			{/if}
		</div>
	</Loader>
</div>

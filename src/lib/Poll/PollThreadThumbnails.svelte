<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import PollThumbnail from './PollThumbnail.svelte';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import PollFiltering from './PollFiltering.svelte';
	import type { Filter, poll, poll as Poll, Post } from './interface';
	import Loader from '$lib/Generic/Loader.svelte';
	import { getUserIsOwner } from '$lib/Group/functions';
	import { pollThumbnails as pollThumbnailsLimit } from '../Generic/APILimits.json';
	import Pagination from '$lib/Generic/Pagination.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import type { DelegateMinimal, Thread } from '$lib/Group/interface';
	import ThreadThumbnail from './Thread.svelte';
	import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';
	import { env } from '$env/dynamic/public';

	export let Class = '',
		infoToGet: 'group' | 'home' | 'public' | 'delegate' | 'user',
		delegate: DelegateMinimal = { id: 0, pool_id: 0, profile_image: '', tags: [], username: '' };

	let posts: Post[] = [],
		filter: Filter = {
			search: '',
			finishedSelection: 'all',
			public: false,
			order_by: 'start_date_desc',
			tag: null
		},
		polls: poll[] = [],
		threads: Thread[] = [],
		loading = false,
		isAdmin = false,
		next = '',
		prev = '',
		poppup: poppup,
		workgroups: WorkGroup[] = [];

	// Only for one-group flowback
	const getWorkGroups = async () => {
		const { res, json } = await fetchRequest('GET', 'group/1/list');

		if (!res.ok) return;

		workgroups = json.results;
	};

	const getAPI = async () => {
		let API = '';
		// console.log(delegate, {}, delegate === {});

		if (infoToGet === 'home') API += `user/home?`;
		// else if (infoToGet === 'group') API += `group/${$page.params.groupId}/poll/list?`;
		else if (infoToGet === 'delegate') API += `group/poll/pool/${delegate.pool_id}/votes`;
		else if (infoToGet === 'user' || infoToGet === 'group')
			API += `user/home?group_ids=${$page.params.groupId}`;
		// else if (infoToGet === 'user') API += `home/polls?`;
		//TODO remove public
		else if (infoToGet === 'public') API += `home/polls?public=true`;

		if (filter.order_by) API += `&order_by=pinned,${filter.order_by}`;
		else API += `&order_by=pinned`;

		// API += `&limit=${pollThumbnailsLimit}`
		API += `&limit=${pollThumbnailsLimit}`;

		if (filter.search.length > 0) API += `&title__icontains=${filter.search}`;

		if (filter.finishedSelection !== 'all')
			API += `&end_date${
				filter.finishedSelection === 'finished' ? '__lt' : '__gt'
			}=${new Date().toISOString()}`;

		// API += '&pinned=false';

		if (filter.tag) API += `&tag_id=${filter.tag}`;

		return API;
	};

	const getPolls = async () => {
		loading = true;
		posts = [];

		const { json, res } = await fetchRequest('GET', await getAPI());

		loading = false;

		if (!res.ok) {
			poppup = { message: 'Could not get polls', success: false };
			return;
		}

		console.log(await getAPI());

		posts = json.results;
		next = json.next;
		prev = json.previous;
	};

	const sharedThreadPollFixing = async () => {
		const pollIds = posts
			//@ts-ignore
			.map((poll) => (poll.related_model === 'poll' ? poll.id : undefined))
			.filter((id) => id !== undefined);

		const threadIds = posts
			//@ts-ignore
			.map((poll) => (poll.related_model === 'group_thread' ? poll.id : undefined))
			.filter((id) => id !== undefined);

		{
			let API = '';

			if (infoToGet === 'home') API = 'home/polls';
			else if (infoToGet === 'group' || infoToGet === 'user')
				API = `group/${$page.params.groupId}/poll/list?id_list=${pollIds.concat()}`;

			const { res, json } = await fetchRequest('GET', API);

			polls = json.results;
		}

		{
			let API = '';
			if (infoToGet === 'home') API = 'group/thread/list?group_ids=1,2,3,4';
			else if (infoToGet === 'group' || infoToGet === 'user')
				API = `group/thread/list?group_ids=${
					$page.params.groupId
				}&limit=1000&order_by=pinned,created_at_desc&id_list=${threadIds.concat()}`;

			const { res, json } = await fetchRequest('GET', API);

			threads = json.results;
		}
	};

	onMount(async () => {
		await getPolls();

		if (env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE') getWorkGroups();
		// else
		sharedThreadPollFixing();

		//TODO: Part of refactoring with svelte stores includes this
		if ($page.params.groupId) isAdmin = (await getUserIsOwner($page.params.groupId)) || false;
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
			{#if posts.length === 0 && !loading}
				<div class="bg-white dark:bg-darkobject rounded shadow p-8 mt-6">
					{$_('No posts currently here')}
				</div>
			{:else}
				<!-- <h1 class="text-3xl text-left">Flow</h1> -->
				{#key posts}
					{#if posts && posts?.length > 0 && (polls.length > 0 || threads.length > 0)}
						{#each posts as post}
							{#if post.related_model === 'group_thread'}
								<ThreadThumbnail
									{isAdmin}
									thread={threads.find((thread) => thread.id === post.id) || threads[0]}
								/>
							{:else if post.related_model === 'poll'}
								<PollThumbnail
									poll={polls.find((poll) => poll.id === post.id) || polls[0]}
									{isAdmin}
								/>
							{/if}
						{/each}
					{:else if !loading}
						<div class="bg-white rounded shadow p-8 dark:bg-darkobject">
							{$_('No posts currently here')}
						</div>
					{/if}
				{/key}
			{/if}
		</div>
		<Pagination
			bind:next
			bind:prev
			bind:iterable={posts}
			Class={'flex gap-2 justify-around w-full mt-6'}
		/>
	</Loader>
</div>

<Poppup bind:poppup />

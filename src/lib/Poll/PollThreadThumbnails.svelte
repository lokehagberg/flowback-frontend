<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/state';
	import { _ } from 'svelte-i18n';
	import { PollsApi } from '$lib/api/polls';
	import { pollThumbnails as pollThumbnailsLimit } from '../Generic/APILimits.json';
	import { InfoToGet, type Filter, type poll, type Post } from './interface';
	import type { Thread } from '$lib/Group/interface';
	import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';
	import { env } from '$env/dynamic/public';
	import { ThreadsApi } from '$lib/api/threads';
	import PollThumbnail from './PollThumbnail.svelte';
	import PollFiltering from './PollFiltering.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import { posts } from './stores';
	import ThreadThumbnail from '$lib/Thread/ThreadThumbnail.svelte';
	import { lazyLoading } from '$lib/Generic/GenericFunctions';
	import { fetchRequest } from '$lib/FetchRequest';

	// Props
	export let Class = '',
		infoToGet: InfoToGet;
	let polls: poll[] = [],
		threads: Thread[] = [],
		workGroups: WorkGroup[] = [],
		loading = false,
		next: null | undefined | string,
		filter: Filter = {
			search: '',
			finishedSelection: 'all',
			public: false,
			order_by: page.params.groupId ? 'pinned' : 'created_at_desc',
			tag: null,
			workgroup: null,
			from: new Date(0).toISOString().slice(0, 16),
			to: new Date(99999999999999).toISOString().slice(0, 16),
			status: null
		},
		showThreads = true,
		showPolls = true;

	async function fetchPolls() {
		let api_params = `
		group_ids=${page.params.groupId ?? ''}&
		order_by=${filter.order_by}&
		limit=${pollThumbnailsLimit}&
		title__icontains=${filter.search ?? ''}&
		tag_id=${filter.tag ?? ''}&
		work_group_ids=${filter.workgroup}&
		public=${infoToGet === InfoToGet.public ? 'true' : ''}&
		created_at__gt=${filter.from}&
		created_at__lt=${filter.to}
    `;

		// When first time loading, or when first time changing the filter, next is undefined.
		// The starting point for the pollthread thumbnails list.
		if (next === undefined) {
			// if (true) {
			loading = true;

			const { res, json } = await fetchRequest(
				'GET',
				`user/home?${api_params}`
			);

			loading = false;
			if (!res.ok)
				ErrorHandlerStore.set({
					message: 'Could not get polls',
					success: false
				});

			$posts = json.results ?? [];
			next = json.next ?? null;

			// Next is null whenever one has reached the last next-page for the api
		} else if (next === null) return;
		else {
			loading = true;
			const { res, json } = await fetchRequest('GET', next);
			if (!res.ok) {
				ErrorHandlerStore.set({
					message: 'Could not load more polls',
					success: false
				});
			}
			$posts = [...$posts, ...json.results];
			next = json.next;
		}
		loading = false;
	}

	const fetchRelatedContent = async () => {
		const threadIds = $posts
			.filter((post) => post.related_model === 'thread')
			.map((post) => post.id);

		const { res, json } = await fetchRequest('GET', `home/polls?limit=1000`);
		polls = json.results;

		if (threadIds.length) {
			const response =
				infoToGet === InfoToGet.home
					? await ThreadsApi.getHomeThreads(filter.order_by)
					: await ThreadsApi.getGroupThreads(
							page.params.groupId ?? '-1',
							threadIds,
							filter.order_by
						);
			threads = response.results;
		}
	};

	async function fetchWorkGroups() {
		const { results } = await PollsApi.getWorkGroups();
		workGroups = results;
	}

	const matchesFilter = (post: Post): boolean => {
		// Find the corresponding thread (only needed for workgroup filtering on threads)
		const thread =
			post.related_model === 'thread'
				? threads.find((t) => t.id === post.id)
				: null;

		// Check search filter (applies to both polls and threads, case-insensitive search on title)
		const matchesSearch =
			!filter.search ||
			post.title?.toLowerCase().includes(filter.search.toLowerCase());

		// Check workgroup filter (only for threads, skipped if both showThreads and showPolls are true)
		const matchesWorkgroup =
			// post.related_model !== 'thread' || // Skip workgroup filter for polls
			// (showThreads && showPolls) || // Skip workgroup filter if both showThreads and showPolls are true
			!filter.workgroup || // If no workgroup filter, show all threads
			(thread && thread.work_group?.id === Number(filter.workgroup)); // Match thread workgroup

		const matchesStatus =
			!filter.status || // Show anything if no status selected
			(post.related_model === 'poll' &&
				//@ts-ignore
				((filter.status === 'finished' && post.status === 1) ||
					//@ts-ignore
					(filter.status === 'ongoing' && post.status === 0)));

		return (matchesSearch && matchesWorkgroup && matchesStatus) || false;
	};

	onMount(async () => {
		await fetchPolls();

		if (env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE') {
			await fetchWorkGroups();
		} else {
			await fetchRelatedContent();
		}
	});

	$: if (filter) {
		next = undefined;
		fetchPolls();
		fetchRelatedContent();
	}
</script>

<svelte:window onscroll={() => lazyLoading(fetchPolls)} />

<div class={`${Class} dark:text-darkmodeText`}>
	<Loader bind:loading>
		<div class={`flex flex-col gap-6 w-full`} id="thumbnails">
			<PollFiltering {infoToGet} bind:filter bind:showThreads bind:showPolls />

			{#if $posts?.length === 0 && !loading}
				<div class="bg-white dark:bg-darkobject rounded shadow p-8 mt-6">
					{$_('No posts currently here')}
				</div>
			{:else if $posts?.length > 0 && (polls?.length > 0 || threads?.length > 0)}
				{#each $posts as post}
					{#if post?.related_model === 'thread' && showThreads && matchesFilter(post)}
						<ThreadThumbnail
							thread={threads?.find((thread) => thread?.id === post?.id) ||
								threads[0]}
						/>
					{:else if post?.related_model === 'poll' && showPolls && matchesFilter(post)}
						<PollThumbnail
							poll={polls?.find((poll) => poll?.id === post?.id) || polls[0]}
						/>
					{/if}
				{/each}
			{:else if !loading}
				<div class="bg-white rounded shadow p-8 dark:bg-darkobject">
					{$_('No posts currently here')}
				</div>
			{/if}
		</div>
		<!-- <Pagination
			bind:next
			bind:prev
			bind:iterable={$posts}
			Class={'flex gap-2 justify-around w-full mt-6'}
		/> -->
	</Loader>
</div>

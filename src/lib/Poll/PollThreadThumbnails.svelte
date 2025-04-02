<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { _ } from 'svelte-i18n';
	import { PollsApi } from '$lib/api/polls';
	import { pollThumbnails as pollThumbnailsLimit } from '../Generic/APILimits.json';
	import type { Filter, poll, Post } from './interface';
	import type { DelegateMinimal, Thread } from '$lib/Group/interface';
	import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';
	import type { poppup } from '$lib/Generic/Poppup';
	import { getUserIsOwner } from '$lib/Group/functions';
	import { env } from '$env/dynamic/public';
	
	import PollThumbnail from './PollThumbnail.svelte';
	import PollFiltering from './PollFiltering.svelte';
	import ThreadThumbnail from './Thread.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import Pagination from '$lib/Generic/Pagination.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';

	// Props
	export let Class = '';
	export let infoToGet: 'group' | 'home' | 'public' | 'delegate' | 'user';
	export let delegate: DelegateMinimal = { 
		id: 0, 
		pool_id: 0, 
		profile_image: '', 
		tags: [], 
		username: '' 
	};

	// State
	let posts: Post[] = [];
	let polls: poll[] = [];
	let threads: Thread[] = [];
	let workgroups: WorkGroup[] = [];
	let loading = false;
	let isAdmin = false;
	let next = '';
	let prev = '';
	let poppup: poppup;
	
	let filter: Filter = {
		search: '',
		finishedSelection: 'all',
		public: false,
		order_by: 'start_date_desc',
		tag: null
	};

	let showThreads = true;
	let showPolls = true;

	// Fetch related content on filter changes
	$: if (filter) {
		fetchPolls();
		fetchRelatedContent();
	}

	// Add sorting reactive statement here
	$: {
		if (posts.length) {
			const sortedPosts = [...posts].sort((a, b) => {
				switch (filter.order_by) {
					case 'start_date_desc':
						return new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime();
					case 'start_date_asc':
						return new Date(a.updated_at).getTime() - new Date(b.updated_at).getTime();
					default:
						return 0;
				}
			});
			posts = sortedPosts;
		}
	}

	async function fetchPolls() {
		try {
			loading = true;
			posts = [];

			const params = {
				order_by: filter.order_by ? `pinned,${filter.order_by}` : 'pinned',
				limit: pollThumbnailsLimit,
				title__icontains: filter.search || undefined,
				tag_id: filter.tag || undefined,
				group_ids: infoToGet === 'group' ? $page.params.groupId : undefined,
				public: infoToGet === 'public' ? true : undefined,
				...(filter.finishedSelection !== 'all' && {
					[`end_date${filter.finishedSelection === 'finished' ? '__lt' : '__gt'}`]: new Date().toISOString()
				})
			};

			const response = await PollsApi.getPosts(infoToGet, params, delegate.pool_id);
			posts = response.results;
			next = response.next ?? '';
			prev = response.previous ?? '';
		} catch (error) {
			poppup = { message: 'Could not get polls', success: false };
		} finally {
			loading = false;
		}
	}

	async function fetchRelatedContent() {
		const pollIds = posts
			.filter(post => post.related_model === 'poll')
			.map(post => post.id);

		const threadIds = posts
			.filter(post => post.related_model === 'group_thread')
			.map(post => post.id);

		if (pollIds.length) {
			const response = await PollsApi.getPolls(
				infoToGet === 'home' ? null : $page.params.groupId,
				pollIds,
				filter.order_by
			);
			polls = response.results;
		}

		if (threadIds.length) {
			const response = await PollsApi.getThreads(
				infoToGet === 'home' ? null : $page.params.groupId,
				threadIds,
				filter.order_by
			);
			threads = response.results;
		}
	}

	async function fetchWorkGroups() {
		const { results } = await PollsApi.getWorkGroups();
		workgroups = results;
	}

	onMount(async () => {
		await fetchPolls();

		if (env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE') {
			await fetchWorkGroups();
		} else {
			await fetchRelatedContent();
		}

		if ($page.params.groupId) {
			isAdmin = await getUserIsOwner($page.params.groupId) || false;
		}
	});
</script>
<div class={`${Class} dark:text-darkmodeText`}>
	<Loader bind:loading>
		<div class={`flex flex-col gap-6 w-full`}>
			<PollFiltering
				tagFiltering={infoToGet === 'group'}
				handleSearch={fetchPolls}
				bind:filter
				bind:showThreads
				bind:showPolls
			/>
			
			{#if posts.length === 0 && !loading}
				<div class="bg-white dark:bg-darkobject rounded shadow p-8 mt-6">
					{$_('No posts currently here')}
				</div>
			{:else}
				{#key posts}
					{#if posts?.length > 0 && (polls.length > 0 || threads.length > 0)}
						{#each posts as post}
							{#if post.related_model === 'group_thread' && showThreads}
								<ThreadThumbnail
									{isAdmin}
									thread={threads.find((thread) => thread.id === post.id) || threads[0]}
								/>
							{:else if post.related_model === 'poll' && showPolls}
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

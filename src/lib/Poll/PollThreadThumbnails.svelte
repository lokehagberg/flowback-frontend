<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import PollThumbnail from './PollThumbnail.svelte';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import PollFiltering from './PollFiltering.svelte';
	import type { Filter, poll, Post } from './interface';
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

	// API Helpers
	const buildApiUrl = async () => {
		const params = new URLSearchParams();
		
		// Base URL
		let baseUrl = '';
		if (infoToGet === 'home') {
			baseUrl = 'user/home';
		} else if (infoToGet === 'delegate') {
			baseUrl = `group/poll/pool/${delegate.pool_id}/votes`;
		} else if (infoToGet === 'user' || infoToGet === 'group') {
			baseUrl = `user/home`;
			params.append('group_ids', $page.params.groupId);
		} else if (infoToGet === 'public') {
			baseUrl = 'home/polls';
			params.append('public', 'true');
		}

		// Add common params
		params.append('order_by', filter.order_by ? `pinned,${filter.order_by}` : 'pinned');
		params.append('limit', pollThumbnailsLimit.toString());

		// Add conditional params
		if (filter.search) params.append('title__icontains', filter.search);
		if (filter.finishedSelection !== 'all') {
			const comparison = filter.finishedSelection === 'finished' ? '__lt' : '__gt';
			params.append(`end_date${comparison}`, new Date().toISOString());
		}
		if (filter.tag) params.append('tag_id', filter.tag.toString());

		return `${baseUrl}?${params.toString()}`;
	};

	const fetchPolls = async () => {
		loading = true;
		posts = [];

		const apiUrl = await buildApiUrl();
		const { json, res } = await fetchRequest('GET', apiUrl);

		if (!res.ok) {
			poppup = { message: 'Could not get polls', success: false };
			loading = false;
			return;
		}

		posts = json.results;
		next = json.next;
		prev = json.previous;
		loading = false;
	};

	const fetchRelatedContent = async () => {
		const pollIds = posts
			.filter(post => post.related_model === 'poll')
			.map(post => post.id);

		const threadIds = posts
			.filter(post => post.related_model === 'group_thread')
			.map(post => post.id);

		// Fetch polls
		if (pollIds.length) {
			const pollsUrl = infoToGet === 'home' 
				? `home/polls?order_by=${filter.order_by}`
				: `group/${$page.params.groupId}/poll/list?id_list=${pollIds.join(',')}&order_by=${filter.order_by}`;
			
			const { json } = await fetchRequest('GET', pollsUrl);
			polls = json.results;
		}

		// Fetch threads
		if (threadIds.length) {
			const threadsUrl = infoToGet === 'home'
				? `group/thread/list?group_ids=1,2,3,4&order_by=${filter.order_by}`
				: `group/thread/list?group_ids=${$page.params.groupId}&limit=1000&order_by=pinned,${filter.order_by}&id_list=${threadIds.join(',')}`;
			
			const { json } = await fetchRequest('GET', threadsUrl);
			threads = json.results;
		}
	};

 	// Only for one-group flowback
	const fetchWorkGroups = async () => {
		const { res, json } = await fetchRequest('GET', 'group/1/list');
		if (res.ok) workgroups = json.results;
	};

	// Lifecycle
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

	// Fetch related content on filter changes
	$: if (filter) {
		fetchPolls();
		fetchRelatedContent();
	}
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

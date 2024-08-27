<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Loader from '$lib/Generic/Loader.svelte';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import type { DelegatePool, VoteHistory } from './interfaces';
	import { _ } from 'svelte-i18n';
	import type { User } from '$lib/User/interfaces';
	import { goto } from '$app/navigation';
	import Comments from '$lib/Comments/Comments.svelte';

	export let history: null | number;

	let loading = false,
		delegatePool: DelegatePool,
		votingHistory: VoteHistory[] = [],
		user: User;

	const getDelegateHistory = async () => {
		loading = true;
		// const { res, json } = await fetchRequest('GET', `group/poll/pool/${history}/poll/votes`);
		const { json, res } = await fetchRequest('GET', `group/poll/pool/${history}/votes`);
		loading = false;
		if (res.ok) votingHistory = json.results;
	};

	const getDelegateInfo = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegate/pools?id=${history}`
		);

		delegatePool = json.results[0];
	};

	const getUserInfo = async () => {
		//@ts-ignore
		const userId = delegatePool.delegates[0].group_user.id;
		const { res, json } = await fetchRequest('GET', `users?id=${userId}`);

		if (!res.ok) return {};
		user = json.results[0];
	};

	onMount(async () => {
		await getDelegateInfo();
		await getDelegateHistory();
		await getUserInfo();

		let query = new URLSearchParams($page.url.searchParams.toString());
		query.set('history_id', delegatePool.id.toString());
		goto(`?${query.toString()}`);
	});
</script>

<Loader bind:loading>
	{#if delegatePool}
		<div class="p3">
			{$_('delegate history for')}
			{user?.username}
		</div>
	{/if}
	<ul class="w-full">
		{#each votingHistory as vote}
			<li
				class="bg-white dark:bg-darkobject dark:text-darkmodeText p-3 w-full flex justify-between items-center"
			>
				<a
					class="w-full break-words text-left text-xl p-1 pl-0 dark:text-darkmodeText cursor-pointer hover:underline"
					href={`${$page.params.groupId}/polls/${vote.poll_id}`}
				>
					{vote.poll_title}</a
				>
			</li>

			<!-- <ul class="w-full block ml-4">
				{#each votingHistory as vote}
					<li
						class="bg-white dark:bg-darkobject dark:text-darkmodeText p-3 w-full flex justify-between items-center"
					>
						{vote.poll_title}
					</li>
				{/each}
			</ul> -->
		{/each}
	</ul>
	<div>
		<Comments api="delegate-history" on:keydown={() => {}} delegate_pool_id={history} />
	</div>
</Loader>

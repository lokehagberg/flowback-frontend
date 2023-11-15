<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Loader from '$lib/Generic/Loader.svelte';
	import { onMount } from 'svelte';
	import json from './Delegationtest.json';
	import { page } from '$app/stores';
	import type { DelegatePool, VoteHistory } from './interfaces';
	import { _ } from 'svelte-i18n';

	export let history: null | number;

	let loading = false,
		delegatePool: DelegatePool,
		votingHistory: VoteHistory[] = [];

	const getDelegateHistory = async () => {
		loading = true;
		// const { res, json } = await fetchRequest('GET', `group/poll/pool/${history}/poll/votes`);
		const { json, res } = await fetchRequest('GET', `group/poll/pool/${history}/votes`);
		loading = false;

		votingHistory = json.results;
	};

	onMount(() => {
		getDelegateHistory();
	});
</script>

<Loader bind:loading>
	<div class="p3">{$_('delegate history for')} {delegatePool?.delegates[0].user_id || ''}</div>
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
</Loader>

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Loader from '$lib/Generic/Loader.svelte';
	import { onMount } from 'svelte';
	import json from './Delegationtest.json';
	import { page } from '$app/stores';
	import type { DelegatePool } from './interfaces';

	export let history: null | number;

	let loading = false,
		delegatePool: DelegatePool;

	const getDelegateHistory = async () => {
		loading = true;
		// const { res, json } = await fetchRequest('GET', `group/poll/pool/${history}/poll/votes`);
		const json= await fetchRequest(
			'GET',
			`group/poll/pool/${history}/poll/votes`
			);
			loading = false;
		
		// delegatePool = json.results[0];
	};

	onMount(() => {
		getDelegateHistory();
	});
</script>

<Loader bind:loading>
	<div class="p3">delegate history for {delegatePool?.delegates[0].user_id || ''}</div>
	<ul class="w-full">
		{#each json as poll}
			<li
				class="bg-white dark:bg-darkobject dark:text-darkmodeText p-3 w-full flex justify-between items-center"
			>
				<a
					class="w-full break-words text-left text-xl p-1 pl-0 dark:text-darkmodeText cursor-pointer hover:underline"
					href={`group/${$page.params.groupId}/poll/${poll.poll_id}`}
				>
					{poll.poll_title}</a
				>
			</li>
			<ul class="w-full block ml-4">
				{#each poll.vote as vote}
					<li
						class="bg-white dark:bg-darkobject dark:text-darkmodeText p-3 w-full flex justify-between items-center"
					>
						{vote.proposal_title}
					</li>
				{/each}
			</ul>
		{/each}
	</ul>
</Loader>

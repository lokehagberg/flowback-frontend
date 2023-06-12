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
		loading = false;
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegate/pools?id=${history}`
		);
		delegatePool = json.results[0];
	};

	onMount(() => {
		getDelegateHistory();
	});
</script>

<Loader bind:loading>
	<div>delegate history for {delegatePool?.delegates[0].user_id || ''}</div>

	<ul class="w-full">
		{#each json as poll}
        <li class="bg-white dark:bg-darkobject dark:text-darkmodeText p-3 w-full border-b-2 border-gray-200 flex justify-between items-center">
			<div class="block">{poll.poll_title}</div>
        </li>
        <ul class="w-full block">
            {#each poll.vote as vote}
            <li class="bg-white dark:bg-darkobject dark:text-darkmodeText p-3 w-full border-b-2 border-gray-200 flex justify-between items-center">{vote.proposal_title}</li>
            {/each}
        </ul>
		{/each}
	</ul>
</Loader>

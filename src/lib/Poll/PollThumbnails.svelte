<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import PollThumbnail from './PollThumbnail.svelte';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import PollFiltering from './PollFiltering.svelte';
	import type { Filter } from './interface';
	import Loader from '$lib/Generic/Loader.svelte';

	export let Class = '';
	export let infoToGet: 'group' | 'home' | 'public';
	let polls: any[] = [];
	let filter: Filter = { search: '', finished: false, public: false };
	let loading = false;

	const getPolls = async () => {
		loading = true;

		const API =
			infoToGet === 'group'
				? `group/${$page.params.groupId}/poll/list?limit=100&title__icontains=${filter.search || ''}`
				: infoToGet === 'home'
				? `home/polls?limit=30&title__icontains=${filter.search || ''}`
				: infoToGet === 'public'
				? `home/polls?limit=30&public=true&title__icontains=${filter.search || ''}`
				: '';

		const { json } = await fetchRequest('GET', API);
		polls = json.results;
		loading = false;
	};

	onMount(() => {
		getPolls();
	});
</script>

<div class={`${Class} `}>
	<Loader bind:loading>
		<div class={`flex flex-col gap-6 `}>
			<PollFiltering handleSearch={getPolls} bind:filter />
			{#if polls.length === 0}
				<div class="bg-white rounded shadow p-8 mt-6">
					{$_('No polls currently here')}
				</div>
			{:else}
				<!-- <h1 class="text-3xl text-left">Flow</h1> -->

				{#if polls.length > 0}
					{#each polls as poll}
						<PollThumbnail {poll}  />
					{/each}
				{:else}
					<div class="bg-white rounded shadow p-8">{$_('No polls currently here')}</div>
				{/if}
			{/if}
		</div>
	</Loader>
</div>

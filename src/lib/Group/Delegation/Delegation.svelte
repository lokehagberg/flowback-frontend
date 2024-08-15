<script lang="ts">
	/*
		Code is not very good in this folder, refactoring almost from scratch needed
		that incorporates features such as delegation pools.
		Design in Figma should be done first 
	*/
	import Selected from './Selected.svelte';
	import Tab from '$lib/Generic/Tab.svelte';
	import All from './All.svelte';
	import History from './History.svelte';
	import NewDelegations from './NewDelegations.svelte';

	let selectedPage: 'All' | 'Selected' | 'History' = 'All',
		history: number | null = null;

	// $: if (history) selectedPage = 'History';
</script>

<div
	class="flex flex-col items-center gap-2 mb-24 bg-white rounded shadow p-4 dark:bg-darkobject dark:text-darkmodeText"
>
	<Tab tabs={['All', 'Selected']} bind:selectedPage />
	{#if selectedPage === 'Selected'}
		<Selected />
	{:else if selectedPage === 'All'}
		<All bind:history bind:selectedPage/>
	{:else if selectedPage === 'History'}
		<History bind:history />
	{/if}
</div>

<NewDelegations />
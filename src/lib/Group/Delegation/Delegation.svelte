<script lang="ts">
	import Selected from './Selected.svelte';

	/*
		Code is not very good in this folder, refactoring almost from scratch needed
		that incorporates new feature such as delegation pools.
		Design in Figma should be done first 
	*/

	import Tab from '$lib/Generic/Tab.svelte';
	import All from './All.svelte';

	let selectedPage: 'All' | 'Selected' = 'All';
</script>

<div class="flex flex-col items-center gap-2 mb-24 bg-white rounded shadow p-4 dark:bg-darkobject dark:text-darkmodeText">
	<Tab tabs={['All', 'Selected']} bind:selectedPage />
	{#if selectedPage === 'Selected'}
		<Selected />
	{:else if selectedPage === 'All'}
		<All />
	{/if}
</div>

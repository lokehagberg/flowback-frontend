<script lang="ts">
  import Selected from './Selected.svelte';

	//Code is not very good in this folder, refactoring from scratch needed
	//that incorporates new feature such as delegation pools.
	//Design in Figma should be done first

	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import Tab from '$lib/Generic/Tab.svelte';
	import All from './All.svelte';
	import { onMount } from 'svelte';

	let selectedPage: 'All' | 'Selected' = 'All';

	const createDelegationPool = async () => {
		fetchRequest('POST', `group/${$page.params.groupId}/delegate/pool/create`, {});
	};

	const deleteDelegationPool = async () => {
		fetchRequest('POST', `group/${$page.params.groupId}/delegate/pool/delete`, {});
	};

	onMount(() => {
		// createDelegationPool()
		// deleteDelegationPool()
	})
</script>

<div class="flex flex-col items-center gap-2 mb-24 bg-white rounded shadow p-4">
	<Tab tabs={['All', 'Selected']} bind:selectedPage={selectedPage} />
	{#if selectedPage === "Selected"}
		<Selected />
		{:else if selectedPage==="All"}
		<All />
	{/if}
</div>


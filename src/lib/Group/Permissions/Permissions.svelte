<script lang="ts">
	import Tab from '$lib/Generic/Tab.svelte';
	import Create from './Create.svelte';
	import Assign from './Assign.svelte';

	let selectedPage: 'assign' | 'create' = 'assign';
</script>

<div class="bg-white p-6 rounded">
	<Tab
		tabs={['assign', 'create']}
		bind:selectedPage
		displayNames={['Assign Roles', 'Create Role']}
	/>
	{#if selectedPage === 'create'}
		<Create />
	{:else if selectedPage === 'assign'}
		<Assign />
	{/if}
</div>

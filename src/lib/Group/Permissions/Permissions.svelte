<script lang="ts">
	import Tab from '$lib/Generic/Tab.svelte';
	import Create from './Create.svelte';
	import Assign from './Assign.svelte';
	import List from './List.svelte';
	import { _ } from 'svelte-i18n';

	let selectedPage: 'assign' | 'create' | 'list' = 'assign';
</script>

<div class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 rounded">
	<h1 class="text-3xl">{$_("Permissions")}</h1>
	<Tab
		tabs={['assign', 'list', 'create']}
		bind:selectedPage
		displayNames={['Assign', 'List', 'Create']}
	/>
	{#if selectedPage === 'create'}
		<Create />
	{:else if selectedPage === 'list'}
		<List />
	{:else if selectedPage === 'assign'}
		<Assign />
	{/if}
</div>

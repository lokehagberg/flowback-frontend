<script lang="ts">
	import Tab from '$lib/Generic/Tab.svelte';
	import Create from './Create.svelte';
	import Assign from './Assign.svelte';
	import List from './List.svelte';
	import { _ } from 'svelte-i18n';
	import type { Permissions } from './interface';

	let selectedPage: 'assign' | 'create' | 'list' = 'assign',
	selectedRole:Permissions;

</script>

<div class="bg-white dark:bg-darkobject dark:text-darkmodeText rounded">
	<!-- <h1 class="text-3xl">{$_("Permissions")}</h1> -->
	<Tab
		tabs={['assign', 'list', 'create']}
		bind:selectedPage
		displayNames={['Assign', 'List', 'Create']}
	/>
	{#if selectedPage === 'create'}
		<Create bind:selectedPage bind:selectedRole/>
	{:else if selectedPage === 'list'}
		<List bind:selectedPage bind:selectedRole/>
	{:else if selectedPage === 'assign'}
		<Assign />
	{/if}
</div>

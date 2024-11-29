<script lang="ts">
	import Layout from '$lib/Generic/Layout.svelte';
	import EditGroup from '$lib/Group/Creation/CreateEditGroup.svelte';
	import Permissions from '$lib/Group/Permissions/Permissions.svelte';
	import Tags from '$lib/Group/Tags.svelte';
	import { _ } from 'svelte-i18n';

	let selectedPage: 'group' | 'areas' | 'perms' | 'blockchain' | null = null;
</script>

<Layout centered>
	<div class="flex w-[80%] mt-6 gap-6">
		<div class="bg-white p-6 shadow">
			<h1 class="text-xl font-semibold text-primary text-left">{$_('Admin Settings')}</h1>
			<ul>
				<li><button on:click={() => (selectedPage = 'group')}>{$_('Edit Group')}</button></li>
				<li><button on:click={() => (selectedPage = 'areas')}>{$_('Areas')}</button></li>
				<li><button on:click={() => (selectedPage = 'perms')}>{$_('Permissions')}</button></li>
				<li><button on:click={() => (selectedPage = 'blockchain')}>{$_('Blockhain')}</button></li>
			</ul>
		</div>
		<div class="bg-white p-6 shadow flex-grow">
			{#if selectedPage === 'group'}
				<EditGroup />
			{:else if selectedPage === 'areas'}
				<Tags />
			{:else if selectedPage === 'perms'}
				<Permissions />
			{:else if selectedPage === 'blockchain'}
				block
			{:else if !selectedPage}
				Nothing
			{/if}
		</div>
	</div>
</Layout>

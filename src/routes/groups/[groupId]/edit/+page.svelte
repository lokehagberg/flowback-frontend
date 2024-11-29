<script lang="ts">
	import { goto } from '$app/navigation';
	import Layout from '$lib/Generic/Layout.svelte';
	import EditGroup from '$lib/Group/Creation/CreateEditGroup.svelte';
	import Permissions from '$lib/Group/Permissions/Permissions.svelte';
	import Tags from '$lib/Group/Tags.svelte';
	import { page } from '$app/stores';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons';

	let selectedPage: 'group' | 'areas' | 'perms' | 'blockchain' | null = null;
</script>

<button
	class="cursor-pointer bg-white dark:bg-darkobject dark:text-darkmodeText justify-center m-auto"
	on:click={() => goto(`/groups/${$page.params.groupId}`)}
>
	<!-- NOTE: In +layout, rote folder, there are URL related behaviours which are affected by this. -->
	<Fa icon={faArrowLeft} />
</button>
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
			{/if}
		</div>
	</div>
</Layout>

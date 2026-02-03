<script lang="ts">
	import { goto } from '$app/navigation';
	import Layout from '$lib/Generic/Layout.svelte';
	import EditGroup from '$lib/Group/Creation/CreateEditGroup.svelte';
	import Permissions from '$lib/Group/Permissions/Permissions.svelte';
	import Tags from '$lib/Group/Tags.svelte';
	import { page } from '$app/stores';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faArrowLeft, faCog, faTags, faShieldAlt } from '@fortawesome/free-solid-svg-icons';
	import { onMount } from 'svelte';
	import { groupUserStore } from '$lib/Group/interface';

	let selectedPage: 'group' | 'areas' | 'perms' | 'blockchain' = 'group',
		optionsDesign =
			'flex items-center gap-3 w-full cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-700 p-2 transition-all';

	onMount(() => {
		// Fixes bug where users who are not admin may navigate and see the admin page
		if (!$groupUserStore?.is_admin) goto(`/groups/${$page.params.groupId}`);
	});
</script>

<Layout centered>
	<div class="flex mt-6 gap-6 max-w-[90%]" class:hidden={!$groupUserStore?.is_admin}>
		<div
			class="bg-white dark:bg-darkobject dark:text-darkmodeText w-[350px] p-6 rounded border shadow"
		>
			<div class="flex items-center mb-4 gap-4">
				<button
					class="text-gray-600 hover:text-primary dark:text-secondary transition-colors"
					on:click={() => goto(`/groups/${$page.params.groupId}`)}
				>
					<Fa icon={faArrowLeft} />
				</button>
				<h1 class="text-xl font-semibold text-primary dark:text-secondary text-left break-word">
					{$_('Admin Settings')}
				</h1>
			</div>
			<div class="mt-4">
				<button
					on:click={() => (selectedPage = 'group')}
					class={`${optionsDesign}`}
					class:bg-gray-100={selectedPage === 'group'}
					class:dark:bg-gray-700={selectedPage === 'group'}
					class:border-l-2={selectedPage === 'group'}
					class:border-primary={selectedPage === 'group'}
				>
					<Fa icon={faCog} class="w-5 h-5" />{$_('Edit Group')}
				</button>
				<button
					on:click={() => (selectedPage = 'areas')}
					class={`${optionsDesign}`}
					class:bg-gray-100={selectedPage === 'areas'}
					class:dark:bg-gray-700={selectedPage === 'areas'}
					class:border-l-2={selectedPage === 'areas'}
					class:border-primary={selectedPage === 'areas'}
				>
					<Fa icon={faTags} class="w-5 h-5" />{$_('Areas')}
				</button>
				<button
					on:click={() => (selectedPage = 'perms')}
					class={`${optionsDesign}`}
					class:bg-gray-100={selectedPage === 'perms'}
					class:dark:bg-gray-700={selectedPage === 'perms'}
					class:border-l-2={selectedPage === 'perms'}
					class:border-primary={selectedPage === 'perms'}
				>
					<Fa icon={faShieldAlt} class="w-5 h-5" />{$_('Permissions')}
				</button>
				<!-- <ul>
				<li
					class={`cursor-pointer ${
						selectedPage === 'blockchain' && 'bg-gray-100 border-l-2 border-primary transition-all'
					}`}
				>
					<button class="w-full text-left" on:click={() => (selectedPage = 'blockchain')}
						>{$_('Blockhain')}</button
					>
				</li>
			</ul> -->
			</div>
		</div>
		<div
			class="bg-white dark:text-darkmodeText dark:bg-darkobject p-6 shadow rounded w-[600px] border"
		>
			{#if selectedPage === 'group'}
				<EditGroup />
			{:else if selectedPage === 'areas'}
				<Tags />
			{:else if selectedPage === 'perms'}
				<Permissions />
			{:else if selectedPage === 'blockchain'}
				<!-- block -->
			{/if}
		</div>
	</div>
</Layout>

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

	let selectedPage: 'group' | 'areas' | 'perms' | 'blockchain' = 'group';
</script>

<Layout centered>
	<div class="flex w-full md:w-[80%] max-w-[1200px] mt-6 md:gap-6 relative">
		<button
			class="cursor-pointer dark:bg-darkobject dark:text-darkmodeText absolute top-0"
			on:click={() => goto(`/groups/${$page.params.groupId}`)}
		>
			<!-- NOTE: In +layout, rote folder, there are URL related behaviours which are affected by this. -->
			<Fa icon={faArrowLeft} />
		</button>
		<div class="bg-white rounded p-6 shadow ml-6 w-[30%]">
			<h1 class="text-xl font-semibold text-primary text-left break-all">{$_('Admin Settings')}</h1>
			<ul>
				<li
					class={`cursor-pointer ${
						selectedPage === 'group' && 'bg-gray-100 border-l-2 border-primary transition-all'
					}`}
				>
					<button class="w-full text-left" on:click={() => (selectedPage = 'group')}
						>{$_('Edit Group')}</button
					>
				</li>
				<li
					class={`cursor-pointer ${
						selectedPage === 'areas' && 'bg-gray-100 border-l-2 border-primary transition-all'
					}`}
				>
					<button class="w-full text-left" on:click={() => (selectedPage = 'areas')}
						>{$_('Areas')}</button
					>
				</li>
				<li
					class={`cursor-pointer ${
						selectedPage === 'perms' && 'bg-gray-100 border-l-2 border-primary transition-all'
					}`}
				>
					<button class="w-full text-left" on:click={() => (selectedPage = 'perms')}
						>{$_('Permissions')}</button
					>
				</li>
				<!-- <li
					class={`cursor-pointer ${
						selectedPage === 'blockchain' && 'bg-gray-100 border-l-2 border-primary transition-all'
					}`}
				>
					<button class="w-full text-left" on:click={() => (selectedPage = 'blockchain')}
						>{$_('Blockhain')}</button
					>
				</li> -->
			</ul>
		</div>
		<div class="bg-white p-6 shadow flex-grow rounded">
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

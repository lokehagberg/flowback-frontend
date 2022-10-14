<script lang="ts">
	import GroupSidebarButton from '$lib/Group/GroupSidebarButton.svelte';
	import type { GroupDetails, SelectablePage } from '$lib/Group/interface';
	import { faFile } from '@fortawesome/free-solid-svg-icons/faFile';
	import { faPeopleArrows } from '@fortawesome/free-solid-svg-icons/faPeopleArrows';
	import { faUserGroup } from '@fortawesome/free-solid-svg-icons/faUserGroup';
	import { faChartColumn } from '@fortawesome/free-solid-svg-icons/faChartColumn';
	import { faCircleInfo } from '@fortawesome/free-solid-svg-icons/faCircleInfo';
	import { faVideoCamera } from '@fortawesome/free-solid-svg-icons/faVideoCamera';
	import { faMailReplyAll } from '@fortawesome/free-solid-svg-icons/faMailReplyAll';
	import { faBars } from '@fortawesome/free-solid-svg-icons/faBars';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faCog } from '@fortawesome/free-solid-svg-icons/faCog';
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	import { page } from '$app/stores';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { mode } from '$lib/Generic/configuration';

	export let selectedPage: SelectablePage = 'flow';
	export let group: GroupDetails;

	let innerWidth = 0;
	let clickedExpandSidebar = false;

	// $: console.log(innerWidth);
</script>

<svelte:window bind:innerWidth />

<div>
	{#if innerWidth < 700 && !clickedExpandSidebar}
		<div on:click={() => (clickedExpandSidebar = true)} class="bg-white p-6 cursor-pointer absolute shadow rounded"><Fa icon={faBars} /></div>
	{:else}
		{#if innerWidth < 700}
			<div on:click={() => (clickedExpandSidebar = false)} class="bg-white p-6 cursor-pointer shadow rounded flex justify-around items-center"><Fa icon={faX} /><span class="ml-2">Close Menu</span></div>
		{/if}
		<div class="bg-white shadow rounded flex flex-col">
			<GroupSidebarButton action={() => (selectedPage = 'flow')} text="Flow" />
			<GroupSidebarButton
				action={() => (selectedPage = 'delegation')}
				text="Delegation"
				icon={faPeopleArrows}
			/>
			{#if mode === "Dev"}
			<GroupSidebarButton
				action={() => (selectedPage = 'documents')}
				text="Documents"
				icon={faFile}
			/>
			{/if}
			<GroupSidebarButton
				action={() => (selectedPage = 'members')}
				text="Members"
				icon={faUserGroup}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'statistics')}
				text="Statistics"
				icon={faChartColumn}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'about')}
				text="About"
				icon={faCircleInfo}
			/>
		</div>
		<div class="bg-white shadow rounded flex flex-col mt-6">
			<GroupSidebarButton
				action={() => (window.location.href = `/createpoll?id=${$page.params.groupId}`)}
				text="Create Poll"
				icon={faPoll}
			/>
			<GroupSidebarButton
				action={() => (window.location.href = `https://meet.flowback.org/${group.jitsi_room}`)}
				text="Video Conference"
				icon={faVideoCamera}
			/>
		</div>
		<div class="bg-white shadow rounded flex flex-col mt-6">
			<GroupSidebarButton
				action={() => (selectedPage = 'email')}
				text="Send Email"
				icon={faMailReplyAll}
			/>
			<GroupSidebarButton action={() => (selectedPage = 'tags')} text="Edit Tags" icon={faCog} />
			<GroupSidebarButton
				action={() => (window.location.href = `/creategroup?group=${$page.params.groupId}`)}
				text="Edit Group"
				icon={faCog}
			/>
		</div>
	{/if}
</div>

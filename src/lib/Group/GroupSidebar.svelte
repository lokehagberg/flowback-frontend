<script lang="ts">
	import GroupSidebarButton from '$lib/Group/GroupSidebarButton.svelte';
	import type { SelectablePage } from '$lib/Group/interface';
	import { page } from '$app/stores';

	export let selectedPage: SelectablePage = 'flow';
</script>

<div>
	<div class="bg-white shadow rounded flex flex-col">
		<GroupSidebarButton action={() => (selectedPage = 'flow')} text="Flow" />
		<GroupSidebarButton action={() => (selectedPage = 'delegation')} text="Delegation" />
		<GroupSidebarButton action={() => (selectedPage = 'documents')} text="Documents" />
		<GroupSidebarButton action={() => (selectedPage = 'members')} text="Members" />
		<GroupSidebarButton action={() => (selectedPage = 'statistics')} text="Statistics" />
		<GroupSidebarButton action={() => (selectedPage = 'about')} text="About" />
	</div>
	<div class="bg-white shadow rounded flex flex-col mt-6">
		<GroupSidebarButton action={() => (window.location.href = '/createpoll')} text="Create Poll" />
		<GroupSidebarButton
			action={() => (window.location.href = '/createpoll')}
			text="Video Conference"
		/>
	</div>
	<div class="bg-white shadow rounded flex flex-col mt-6">
		<GroupSidebarButton action={() => (selectedPage = 'email')} text="Send Email" />
		<GroupSidebarButton action={() => (selectedPage = 'tags')} text="Edit Tags" />
		<GroupSidebarButton
			action={() => (window.location.href = `/creategroup?group=${$page.params.groupId}`)}
			text="Edit Group"
		/>
	</div>
</div>
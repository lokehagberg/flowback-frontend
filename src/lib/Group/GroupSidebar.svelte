<script lang="ts">
	import GroupSidebarButton from '$lib/Group/GroupSidebarButton.svelte';
	import { selectablePages } from '$lib/Group/interface';

	export let selectedPage: selectablePages = selectablePages.delegation;
</script>

<div>
	<div class="bg-white shadow rounded flex flex-col">
		<GroupSidebarButton action={() => (selectedPage = selectablePages.flow)} text="Flow" />
		<GroupSidebarButton
			action={() => (selectedPage = selectablePages.delegation)}
			text="Delegation"
		/>
		<GroupSidebarButton
			action={() => (selectedPage = selectablePages.documents)}
			text="Documents"
		/>
		<GroupSidebarButton action={() => (selectedPage = selectablePages.members)} text="Members" />
		<GroupSidebarButton action={() => (selectedPage = selectablePages.statistics)} text="Statistics" />
		<GroupSidebarButton action={() => (selectedPage = selectablePages.about)} text="About" />
	</div>
	<div class="bg-white shadow rounded flex flex-col mt-6">
		<GroupSidebarButton action={() => (window.location.href = '/createpoll')} text="Create Poll" />
		<GroupSidebarButton
			action={() => (window.location.href = '/createpoll')}
			text="Video Conference"
		/>
		<GroupSidebarButton action={() => (selectedPage = selectablePages.email)} text="Send Email" />
	</div>
</div>

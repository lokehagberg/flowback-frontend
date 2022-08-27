<script lang="ts">
	import GroupSidebarButton from '../../lib/Group/GroupSidebarButton.svelte';
	import GroupHeader from '../../lib/Group/GroupHeader.svelte';
	import Header from '$lib/Header/Header.svelte';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import Members from '$lib/Group/Members.svelte';
	import { selectablePages } from '$lib/Group/interface';

	let selectedPage: selectablePages = selectablePages.flow;
</script>

<Header />

<GroupHeader bind:selectedPage />

<div class="flex justify-center mt-16 gap-16">
	<div class="flex justify-center w-2/3">
		{#if selectedPage === 'flow'}
			<PollThumbnails />
		{:else if selectedPage === 'members'}
			<Members />
		{/if}
	</div>

	<div>
		<div class="bg-white shadow rounded flex flex-col">
			<GroupSidebarButton action={() => (selectedPage = selectablePages.flow)} text="Flow" />
			<GroupSidebarButton action={() => (selectedPage = selectablePages.about)} text="About" />
			<GroupSidebarButton
				action={() => (selectedPage = selectablePages.documents)}
				text="Documents"
			/>
			<GroupSidebarButton action={() => (selectedPage = selectablePages.members)} text="Members" />
			<GroupSidebarButton action={() => (selectedPage = selectablePages.email)} text="Send Email" />
			<GroupSidebarButton
				action={() => (selectedPage = selectablePages.stats)}
				text="Group statistics"
			/>
		</div>
		<div class="bg-white shadow rounded flex flex-col mt-6">
			<GroupSidebarButton
				action={() => (window.location.href = '/createpoll')}
				text="Create Poll"
			/>
			<GroupSidebarButton
				action={() => (window.location.href = '/createpoll')}
				text="Video Conference"
			/>
		</div>
	</div>
</div>

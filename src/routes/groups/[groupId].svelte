<script lang="ts">
	import GroupHeader from '../../lib/Group/GroupHeader.svelte';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import Members from '$lib/Group/Members.svelte';
	import { selectablePages } from '$lib/Group/interface';
	import Delegation from '$lib/Group/Delegation.svelte';
	import GroupSidebar from '$lib/Group/GroupSidebar.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
import Documents from '$lib/Group/Documents/Documents.svelte';

	let selectedPage: selectablePages = selectablePages.delegation;
</script>

<Layout>
	<GroupHeader bind:selectedPage />

	<div class="flex justify-center mt-16 gap-16 mb-16">
		<div class="w-2/3">
			{#if selectedPage === 'flow'}
				<PollThumbnails />
			{:else if selectedPage === 'delegation'}
				<Delegation />
			{:else if selectedPage === 'members'}
				<Members />
			{:else if selectedPage === 'documents'}
				<Documents />
			{/if}
		</div>

		<GroupSidebar bind:selectedPage />
	</div>
</Layout>

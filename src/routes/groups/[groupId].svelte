<script lang="ts">
	import GroupHeader from '../../lib/Group/GroupHeader.svelte';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import Members from '$lib/Group/Members.svelte';
	import type { SelectablePage } from '$lib/Group/interface';
	import Delegation from '$lib/Group/Delegation.svelte';
	import GroupSidebar from '$lib/Group/GroupSidebar.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Documents from '$lib/Group/Documents/Documents.svelte';
	import About from '$lib/Group/About.svelte';
	import SendEmail from '$lib/Group/SendEmail.svelte';
	import Statistics from '$lib/Group/Statistics.svelte';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import Tags from '$lib/Group/Tags.svelte';

	interface GroupDetails {
		active: boolean,
		cover_image: string,
		created_by: number,
		default_permission: number | null,
		description: string,
		direct_join: boolean,
		image: string,
		jitsi_room: string,
		name: string,
		public: boolean
	}

	let selectedPage: SelectablePage = 'flow';
	let group: GroupDetails | {} = {};

	onMount(async () => {
		const res = await fetchRequest('GET', `group/${$page.params.groupId}/detail`);
		const json = await res.json();
		group = json.results;
	});
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
			{:else if selectedPage === 'statistics'}
				<Statistics />
			{:else if selectedPage === 'email'}
				<SendEmail />
			{:else if selectedPage === 'about'}
				<About />
			{:else if selectedPage === 'tags'}
				<Tags />
			{/if}
		</div>

		<GroupSidebar bind:selectedPage />
	</div>
</Layout>

<script lang="ts">
	import GroupHeader from '$lib/Group/GroupHeader.svelte';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import Members from '$lib/Group/Members.svelte';
	import {
		userIsDelegateStore,
		type GroupDetails,
		type SelectablePage
	} from '$lib/Group/interface';
	import Delegation from '$lib/Group/Delegation/Delegation.svelte';
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

	let selectedPage: SelectablePage = 'flow';
	let group: GroupDetails = {
		active: false,
		cover_image: '',
		created_by: 0,
		default_permission: null,
		description: '',
		direct_join: false,
		image: '',
		jitsi_room: '',
		name: '',
		public: true,
		id: 0
	};

	onMount(() => {
		getGroupInfo();
		setUserGroupInfo();
	});

	const setUserGroupInfo = async () => {
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/users?id=${1}`);
		userIsDelegateStore.set(json.results[0].delegate);
	};

	const getGroupInfo = async () => {
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/detail`);
		group = json;
	};
</script>

<Layout>
	<GroupHeader bind:selectedPage {group} />

	<div class="flex justify-center">
		<div class="flex justify-center mt-2 md:mt-16 gap-2 md:gap-16 mb-16 w-3/4">
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
					<About description={group.description} />
				{:else if selectedPage === 'tags'}
					<Tags />
				{/if}
			</div>

			<GroupSidebar {group} bind:selectedPage />
		</div>
	</div>
</Layout>

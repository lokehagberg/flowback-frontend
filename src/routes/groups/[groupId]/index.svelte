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
	import Kanban from '$lib/Group/Kanban.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import Permissions from '$lib/Group/Permissions.svelte';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';

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
	let userInGroup: boolean = true,
		memberCount = 0;

	onMount(() => {
		getGroupInfo();
		setUserGroupInfo();

	});

	const setUserGroupInfo = async () => {
		const { res, json } = await fetchRequest('GET', `group/${$page.params.groupId}/users?id=${1}`);
		userIsDelegateStore.set(json.results[0].delegate);
		statusMessageFormatter(res, json);
	};

	const getGroupInfo = async () => {
		const { json, res } = await fetchRequest('GET', `group/${$page.params.groupId}/detail`);
		group = json;
		memberCount = json.member_count;
		userInGroup = !(json.detail && json.detail[0] === 'User is not in group');
		statusMessageFormatter(res, json);
	};
</script>

<svelte:head>
	<title>{group.name}</title>
</svelte:head>

{#if userInGroup}
<!-- <ButtonPrimary action={() => {
	
	// fetchRequest('GET', 'notification/subscriptions')
		fetchRequest('POST', 'notification/read', {notification_ids:[3]})
		fetchRequest('GET', 'notification')
		// fetchRequest('POST', `group/${$page.params.groupId}/subscribe`, {categories: []})
}}/> -->
	<Layout>
		<GroupHeader bind:selectedPage {group} {memberCount} />
		<div class="flex justify-center">
			<div class="flex justify-center mt-4 md:mt-10 lg:mt-16 gap-4 md:gap-10 lg:gap-16 mb-16">
				<div
					class={`w-full sm:w-[300px] md:w-[500px] ${
						selectedPage === 'kanban' ? 'xl:w-[1000px]' : 'xl:w-[720px]'
					}`}
				>
					<!-- TODO: Simplify this, look in SideBarButtons file to simplify more there -->
					{#if selectedPage === 'flow'}
						<PollThumbnails infoToGet="group" />
					{:else if selectedPage === 'delegation'}
						<Delegation />
					{:else if selectedPage === 'members'}
						<Members />
					{:else if selectedPage === 'documents'}
						<Documents />
					{:else if selectedPage === 'statistics'}
						<Statistics {memberCount} />
					{:else if selectedPage === 'email'}
						<SendEmail />
					{:else if selectedPage === 'about'}
						<About description={group.description} creatorId={group.created_by} />
					{:else if selectedPage === 'tags'}
						<Tags />
					{:else if selectedPage === 'kanban'}
						<Kanban type="group" />
					{:else if selectedPage === 'perms'}
						<Permissions />
					{/if}
				</div>

				<GroupSidebar Class={``} {group} bind:selectedPage />
			</div>
		</div>
	</Layout>
{:else}
	<Layout centering={true}>
		<div class="bg-white w-full text-center md:w-1/2 shadow rounded p-16 mt-8">
			You are not a memeber of this group!
		</div>
	</Layout>
{/if}

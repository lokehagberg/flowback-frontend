<script lang="ts">
	import GroupHeader from '$lib/Group/GroupHeader.svelte';
	import Members from '$lib/Group/Members.svelte';
	import { type GroupDetails, type SelectablePage } from '$lib/Group/interface';
	import GroupSidebar from '$lib/Group/GroupSidebar.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import About from '$lib/Group/About.svelte';
	import SendEmail from '$lib/Group/SendEmail.svelte';
	import Statistics from '$lib/Group/Statistics.svelte';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import Tags from '$lib/Group/Tags.svelte';
	import { _ } from 'svelte-i18n';
	import Permissions from '$lib/Group/Permissions/Permissions.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import Schedule from '$lib/Schedule/Schedule.svelte';
	import WorkGroups from '$lib/Group/WorkingGroups/WorkGroups.svelte';
	import { env } from '$env/dynamic/public';
	import PollThreadThumbnails from '$lib/Poll/PollThreadThumbnails.svelte';
	import { InfoToGet } from '$lib/Poll/interface';

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
		memberCount = 0,
		loading = true;

	onMount(() => {
		loading = true;
		getGroupInfo();
	});

	const getGroupInfo = async () => {
		//TODO: detail is outdated
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/detail`
		);
		loading = false;
		if (!res.ok) return;

		group = json;
		// console.log(group, 'GROUPPP');
		memberCount = json.member_count;
		userInGroup = !(json.detail && json.detail[0] === 'User is not in group');
	};

	let hasMounted = false;
	onMount(() => {
		hasMounted = true;
		const page =
			new URLSearchParams(window.location.search).get('page') || 'flow';
		//@ts-ignore
		selectedPage = page;

		window.addEventListener('popstate', handleBackButton);

		return () => {
			window.removeEventListener('popstate', handleBackButton);
		};
	});

	const handleBackButton = () => {
		// const page = new URLSearchParams(window.location.search).get('page') || 'flow';
		//@ts-ignore
		// selectedPage = page;
	};
</script>

<svelte:head>
	{#if group.name && selectedPage}
		<title>{group.name} at {selectedPage}</title>
	{:else}
		<title>Flowback</title>
	{/if}
</svelte:head>

<Layout>
	{#if loading}
		<Loader bind:loading />
	{:else if userInGroup}
		<div class="flex flex-col items-center">
			<GroupHeader bind:selectedPage {group} {memberCount} />
			<div class="flex justify-center gap-6 mt-12">
				<main
					class={`w-[70vw] max-w-[800px] 
				`}
				>
					<!-- Here is where the different pages on a group are selected and switched around with, such as "Flow" page which is 
					here called Pollthumbnails. -->

					<!-- TODO: Simplify this, look in SideBarButtons file to simplify more there -->

					{#if selectedPage === 'flow'}
						<PollThreadThumbnails
							infoToGet={env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE'
								? InfoToGet.user
								: InfoToGet.group}
							Class={`w-full mx-auto my-0`}
						/>
					{:else if selectedPage === 'members'}
						<Members />
						<!-- {:else if selectedPage === 'documents'} -->
						<!-- <Documents /> -->
					{:else if selectedPage === 'statistics'}
						<Statistics {memberCount} />
					{:else if selectedPage === 'email'}
						<SendEmail />
					{:else if selectedPage === 'about'}
						<About
							description={group.description}
							creatorId={group.created_by}
						/>
					{:else if selectedPage === 'tags'}
						<Tags />
					{:else if selectedPage === 'kanban'}
						<!-- <KanbanBoard type="group" /> -->
					{:else if selectedPage === 'perms'}
						<Permissions />
					{:else if selectedPage === 'schedule'}
						<Schedule type="group" />
					{:else if selectedPage === 'working-groups'}
						<WorkGroups />
					{/if}
				</main>

				<GroupSidebar Class={``} {group} bind:selectedPage />
			</div>
		</div>
	{:else}
		<div class="bg-white w-full text-center md:w-1/2 shadow rounded p-16 mt-8">
			{$_('You are not a member of this group!')}
		</div>
	{/if}
</Layout>

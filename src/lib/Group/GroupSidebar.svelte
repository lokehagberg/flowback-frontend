<script lang="ts">
	import GroupSidebarButton from '$lib/Group/GroupSidebarButton.svelte';
	import type { GroupDetails, SelectablePage } from '$lib/Group/interface';
	import { faUserGroup } from '@fortawesome/free-solid-svg-icons/faUserGroup';
	import { faCircleInfo } from '@fortawesome/free-solid-svg-icons/faCircleInfo';
	import { faVideoCamera } from '@fortawesome/free-solid-svg-icons/faVideoCamera';
	import { faMailReplyAll } from '@fortawesome/free-solid-svg-icons/faMailReplyAll';
	import { faPersonRunning } from '@fortawesome/free-solid-svg-icons/faPersonRunning';
	import { faCheckToSlot } from '@fortawesome/free-solid-svg-icons/faCheckToSlot';
	import { faBars } from '@fortawesome/free-solid-svg-icons/faBars';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faCog } from '@fortawesome/free-solid-svg-icons/faCog';
	import { faList } from '@fortawesome/free-solid-svg-icons/faList';
	import { page } from '$app/stores';
	import Fa from 'svelte-fa';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { _ } from 'svelte-i18n';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import { faCoins } from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import { removeGroupMembership } from '$lib/Blockchain_v1_Ethereum/javascript/rightToVote';
	import { env } from '$env/dynamic/public';
	import { getPermissionsFast, getUserIsGroupAdmin } from '$lib/Generic/GenericFunctions';
	import Permissions from './Permissions/Permissions.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import Poppup from '$lib/Generic/Poppup.svelte';

	export let selectedPage: SelectablePage = 'flow',
		group: GroupDetails,
		Class: string;

	let innerWidth = 0,
		clickedExpandSidebar = false,
		userIsOwner = false,
		areYouSureModal = false,
		userIsPermittedToCreatePost = false,
		poppup: poppup;

	const leaveGroup = async () => {
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/leave`);
		if (res.ok) {
			removeGroupMembership(Number($page.params.groupId));
			goto('/home');
		}
	};

	const action = (page: SelectablePage) => {
		if (selectedPage === page) return;
		selectedPage = page;
		goto(`?page=${page}`, { noScroll: true });
	};

	onMount(async () => {
		userIsOwner = await getUserIsGroupAdmin($page.params.groupId);

		const permission: Permissions = await getPermissionsFast($page.params.groupId);
		userIsPermittedToCreatePost =
			(permission !== undefined && permission !== null && permission.create_poll) || userIsOwner;
	});

	//@ts-ignore
	$: selectedPage = $page.url.searchParams.get('page') || 'flow';
</script>

<svelte:window bind:innerWidth />

<!-- TODO: Make it easier to add a sidebarbutton -->
<nav
	class={`${Class} ${
		innerWidth < 700 &&
		`fixed right-0 top-[50%] h-[50%] ${clickedExpandSidebar && 'overflow-y-auto'}`
	} dark:!text-darkmodeText `}
>
	{#if innerWidth < 700 && !clickedExpandSidebar}
		<button
			on:click={() => (clickedExpandSidebar = true)}
			class="bg-white dark:bg-darkobject p-6 cursor-pointer absolute shadow rounded right-0 dark:border-gray-500 border-gray-300 border-2"
		>
			<Fa icon={faBars} />
		</button>
	{:else}
		{#if innerWidth < 700}
			<button
				on:click={() => (clickedExpandSidebar = false)}
				class="bg-white dark:bg-darkobject p-6 cursor-pointer shadow rounded flex justify-around items-center"
			>
				<Fa icon={faX} /><span class="ml-2">{$_('Close Menu')}</span>
			</button>
		{/if}
		<div class="mb-6 w-full">
			<GroupSidebarButton
				action={() => {
					if (userIsPermittedToCreatePost)
						goto(
							`/createpoll?id=${$page.params.groupId}&type=${
								selectedPage === 'threads' ? 'thread' : 'poll'
							}`
						);
					else poppup = { message: 'You do not have permission to create a post', success: false };
				}}
				text="Create a post"
				disabled={!userIsPermittedToCreatePost}
				icon={faCheckToSlot}
				isSelected={false}
				Class="text-white hover:!bg-blue-800 active:!bg-blue-900 bg-primary shadow rounded w-full"
			/>
		</div>
		<div class="bg-white dark:bg-darkobject shadow rounded flex flex-col">
			<GroupSidebarButton
				action={() => action('flow')}
				text="Flow"
				isSelected={selectedPage === 'flow'}
			/>
			<GroupSidebarButton
				action={() => action('threads')}
				text="Threads"
				isSelected={selectedPage === 'threads'}
			/>
			<!-- <GroupSidebarButton
				action={() => action('delegation')}
				isSelected={selectedPage === 'delegation'}
				text="Delegation"
				icon={faPeopleArrows}
			/> -->
			<GroupSidebarButton
				action={() => action('working-groups')}
				text={env.PUBLIC_LOGO === "REFORUM" ? "Work- and local Groups" : "Work Groups"}
				isSelected={selectedPage === 'working-groups'}
				icon={faUserGroup}
			/>
			<!-- <GroupSidebarButton
				action={() => action('documents')}
				isSelected={selectedPage === 'documents'}
				text="Documents"
				icon={faFile}
			/> -->
			{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
				<GroupSidebarButton
					action={() => action('kanban')}
					isSelected={selectedPage === 'kanban'}
					text="Group Kanban"
					icon={faList}
				/>
				<GroupSidebarButton
					action={() => action('schedule')}
					isSelected={selectedPage === 'schedule'}
					text="Group schedule"
					icon={faCalendarAlt}
				/>
			{/if}
			<GroupSidebarButton
				action={() => action('members')}
				text="Members"
				icon={faUserGroup}
				isSelected={selectedPage === 'members'}
			/>
			<!-- <GroupSidebarButton
				action={() => (action('statistics'))}
				text="Statistics"
				icon={faChartColumn}
				isSelected={selectedPage === 'statistics'}
			/> -->
			<a
				class="text-inherit w-full"
				target="_blank"
				href={`https://meet.flowback.org/${group.jitsi_room}`}
			>
				<GroupSidebarButton
					Class="w-full"
					text="Video Conference"
					icon={faVideoCamera}
					isSelected={false}
				/></a
			>
			{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
				<GroupSidebarButton
					action={() => action('about')}
					text="About"
					icon={faCircleInfo}
					isSelected={selectedPage === 'about'}
				/>
			{/if}
		</div>
		{#if env.PUBLIC_FLOWBACK_LEDGER_MODULE === 'TRUE'}
			<div class="bg-white dark:bg-darkobject shadow rounded flex flex-col mt-6">
				{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
					<GroupSidebarButton
						Class="w-full"
						action={() => (areYouSureModal = true)}
						text="Leave group"
						icon={faPersonRunning}
						isSelected={false}
					/>
				{:else}
					<a class="text-inherit w-full" href={`/ledger`}>
						<GroupSidebarButton
							Class="w-full"
							text="Group Ledger"
							icon={faCoins}
							isSelected={false}
						/>
					</a>
				{/if}
			</div>
		{/if}
		{#if userIsOwner}
			<div class="bg-white dark:bg-darkobject shadow rounded flex flex-col mt-6">
				<GroupSidebarButton
					action={() => action('email')}
					text="Send Email"
					icon={faMailReplyAll}
					isSelected={selectedPage === 'email'}
				/>
				<GroupSidebarButton
					action={() => goto(`/groups/${$page.params.groupId}/edit`)}
					text="Edit Group"
					icon={faCog}
					isSelected={false}
				/>
			</div>
		{/if}
	{/if}
</nav>

<Modal bind:open={areYouSureModal}>
	<div slot="header">{$_('Are you sure?')}</div>
	<div slot="body">{$_('You are about to leave the group!')}</div>
	<div slot="footer">
		<Button action={leaveGroup} Class="bg-red-500">{$_('Yes')}</Button>
		<Button action={() => (areYouSureModal = false)} Class="bg-gray-600 w-1/2">{$_('No')}</Button>
	</div>
</Modal>

<Poppup bind:poppup />

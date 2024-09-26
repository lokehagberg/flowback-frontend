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
	import { faPersonRunning } from '@fortawesome/free-solid-svg-icons/faPersonRunning';
	import { faCheckToSlot } from '@fortawesome/free-solid-svg-icons/faCheckToSlot';
	import { faBars } from '@fortawesome/free-solid-svg-icons/faBars';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faCog } from '@fortawesome/free-solid-svg-icons/faCog';
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	import { faList } from '@fortawesome/free-solid-svg-icons/faList';
	import { page } from '$app/stores';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { _ } from 'svelte-i18n';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import { faCoins } from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import { removeGroupMembership } from '$lib/Blockchain/javascript/rightToVote';
	import { env } from '$env/dynamic/public';

	export let selectedPage: SelectablePage = 'flow';
	export let group: GroupDetails;
	export let Class: string;

	let innerWidth = 0;
	let clickedExpandSidebar = false;
	let userIsOwner = false;
	let areYouSureModal = false;

	// $: console.log(innerWidth);

	//TODO: More complicated system for this, aswell as storing user info in localstorage or svelte stores
	const getUserIsOwner = async () => {
		const userData = await fetchRequest('GET', 'user');
		const groupAdmins = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?is_admin=true`
		);

		userIsOwner =
			groupAdmins.json.results.find(
				(user: any) => user.user.id === userData.json.id && user.is_admin
			) !== undefined;
	};

	const leaveGroup = async () => {
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/leave`);
		if (res.ok) {
			removeGroupMembership(Number($page.params.groupId));
			goto('/home');
		}
	};

	onMount(() => {
		getUserIsOwner();
	});

	$: selectedPage && (() => (clickedExpandSidebar = false))();
</script>

<svelte:window bind:innerWidth />

<!-- TODO: Make it easier to add a sidebarbutton -->
<nav
	class={`${Class} ${
		innerWidth < 700 &&
		`fixed right-0 top-[50%] h-[50%] ${clickedExpandSidebar && 'overflow-y-scroll'}`
	} dark:!text-darkmodeText `}
>
	{#if innerWidth < 700 && !clickedExpandSidebar}
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<div
			on:click={() => (clickedExpandSidebar = true)}
			class="bg-white dark:bg-darkobject p-6 cursor-pointer absolute shadow rounded right-0 dark:border-gray-500 border-gray-300 border-2"
			on:keydown
		>
			<Fa icon={faBars} />
		</div>
	{:else}
		{#if innerWidth < 700}
			<!-- svelte-ignore a11y-no-static-element-interactions -->
			<div
				on:click={() => (clickedExpandSidebar = false)}
				class="bg-white dark:bg-darkobject p-6 cursor-pointer shadow rounded flex justify-around items-center"
				on:keydown
			>
				<Fa icon={faX} /><span class="ml-2">{$_('Close Menu')}</span>
			</div>
		{/if}
		<div class="mb-6 w-full">
			<div class="bg-primary text-white shadow rounded flex flex-col">
				<a class="text-white" href={`/createpoll?id=${$page.params.groupId}`}>
					<GroupSidebarButton text="Create A post" icon={faCheckToSlot} isSelected={false} /></a
				>
			</div>
		</div>
		<div class="bg-white dark:bg-darkobject shadow rounded flex flex-col">
			<GroupSidebarButton
				action={() => (selectedPage = 'flow')}
				text="Flow"
				isSelected={selectedPage === 'flow'}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'threads')}
				text="Threads"
				isSelected={selectedPage === 'threads'}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'delegation')}
				isSelected={selectedPage === 'delegation'}
				text="Delegation"
				icon={faPeopleArrows}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'working-groups')}
				text="Work Groups"
				isSelected={selectedPage === 'working-groups'}
				icon={faUserGroup}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'documents')}
				isSelected={selectedPage === 'documents'}
				text="Documents"
				icon={faFile}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'kanban')}
				isSelected={selectedPage === 'kanban'}
				text="Group Kanban"
				icon={faList}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'schedule')}
				isSelected={selectedPage === 'schedule'}
				text="Group schedule"
				icon={faCalendarAlt}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'members')}
				text="Members"
				icon={faUserGroup}
				isSelected={selectedPage === 'members'}
			/>
			<!-- <GroupSidebarButton
				action={() => (selectedPage = 'statistics')}
				text="Statistics"
				icon={faChartColumn}
				isSelected={selectedPage === 'statistics'}
			/> -->
			{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
				<GroupSidebarButton
					action={() => (selectedPage = 'about')}
					text="About"
					icon={faCircleInfo}
					isSelected={selectedPage === 'about'}
				/>
			{/if}
		</div>
		<div class="bg-white dark:bg-darkobject shadow rounded flex flex-col mt-6">
			<!-- These two are link tags so people are able to open them in new window/tab -->
			<a
				class="text-inherit"
				target="_blank"
				href={`https://meet.flowback.org/${group.jitsi_room}`}
			>
				<GroupSidebarButton text="Video Conference" icon={faVideoCamera} isSelected={false} /></a
			>
			{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
				<GroupSidebarButton
					action={() => (areYouSureModal = true)}
					text="Leave group"
					icon={faPersonRunning}
					isSelected={false}
				/>
			{:else}
				<a class="text-inherit" href={`/ledger`}>
					<GroupSidebarButton text="Group Ledger" icon={faCoins} isSelected={false} />
				</a>
			{/if}
		</div>
		{#if userIsOwner}
			<div class="bg-white dark:bg-darkobject shadow rounded flex flex-col mt-6">
				<GroupSidebarButton
					action={() => (selectedPage = 'email')}
					text="Send Email"
					icon={faMailReplyAll}
					isSelected={selectedPage === 'email'}
				/>
				<GroupSidebarButton
					action={() => (selectedPage = 'tags')}
					text="Edit Tags"
					icon={faCog}
					isSelected={selectedPage === 'tags'}
				/>
				<GroupSidebarButton
					action={() => (selectedPage = 'perms')}
					text="Permissions"
					icon={faCog}
					isSelected={selectedPage === 'perms'}
				/>
				<GroupSidebarButton
					action={() => goto(`/creategroup?group=${$page.params.groupId}`)}
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

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
	import { faBars } from '@fortawesome/free-solid-svg-icons/faBars';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faCog } from '@fortawesome/free-solid-svg-icons/faCog';
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	import { page } from '$app/stores';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';

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
				(user: any) => user.user_id === userData.json.id && user.is_admin
			) !== undefined;
	};

	const leaveGroup = async () => {
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/leave`);
		if (res.ok) window.location.href = '/home';
	};

	onMount(() => {
		getUserIsOwner();
	});
</script>

<svelte:window bind:innerWidth />

<div class={`${Class} ${innerWidth < 700 && `absolute left-0 top-[50%]`}`}>
	{#if innerWidth < 700 && !clickedExpandSidebar}
		<div
			on:click={() => (clickedExpandSidebar = true)}
			class="bg-white p-6 cursor-pointer absolute shadow rounded"
		>
			<Fa icon={faBars} />
		</div>
	{:else}
		{#if innerWidth < 700}
			<div
				on:click={() => (clickedExpandSidebar = false)}
				class="bg-white p-6 cursor-pointer shadow rounded flex justify-around items-center"
			>
				<Fa icon={faX} /><span class="ml-2">Close Menu</span>
			</div>
		{/if}
		<div class="bg-white shadow rounded flex flex-col">
			<GroupSidebarButton
				action={() => (selectedPage = 'flow')}
				text="Flow"
				isSelected={selectedPage === 'flow'}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'delegation')}
				isSelected={selectedPage === 'delegation'}
				text="Delegation"
				icon={faPeopleArrows}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'documents')}
				isSelected={selectedPage === 'documents'}
				text="Documents"
				icon={faFile}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'members')}
				text="Members"
				icon={faUserGroup}
				isSelected={selectedPage === 'members'}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'statistics')}
				text="Statistics"
				icon={faChartColumn}
				isSelected={selectedPage === 'statistics'}
			/>
			<GroupSidebarButton
				action={() => (selectedPage = 'about')}
				text="About"
				icon={faCircleInfo}
				isSelected={selectedPage === 'about'}
			/>
		</div>
		<div class="bg-white shadow rounded flex flex-col mt-6">
			<!-- These two are link tags so people are able to open them in new window/tab -->
			<a class="text-black" href={`/createpoll?id=${$page.params.groupId}`}><GroupSidebarButton
				text="Create Poll"
				icon={faPoll}
				isSelected={false}
			/></a>
			<a class="text-black" href={`https://meet.flowback.org/${group.jitsi_room}`}> <GroupSidebarButton
				text="Video Conference"
				icon={faVideoCamera}
				isSelected={false}
			/></a>
			<GroupSidebarButton
				action={() => (areYouSureModal = true)}
				text="Leave group"
				icon={faPersonRunning}
				isSelected={false}
			/>
		</div>
		{#if userIsOwner}
			<div class="bg-white shadow rounded flex flex-col mt-6">
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
					action={() => (window.location.href = `/creategroup?group=${$page.params.groupId}`)}
					text="Edit Group"
					icon={faCog}
					isSelected={false}
				/>
			</div>
		{/if}
	{/if}
</div>

<Modal bind:open={areYouSureModal}>
	<div slot="header">Är du säker?</div>
	<div slot="body">Du är påväg att lämna gruppen!</div>
	<div slot="footer">
		<ButtonPrimary action={leaveGroup} Class="bg-red-500">Ja</ButtonPrimary>
		<ButtonPrimary action={() => (areYouSureModal = false)} Class="bg-gray-600 w-1/2"
			>Nej</ButtonPrimary
		>
	</div>
</Modal>

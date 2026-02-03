<script lang="ts">
	import { type WorkGroup, type WorkGroupUser } from './interface';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faTrash } from '@fortawesome/free-solid-svg-icons';
	import { groupUserStore } from '$lib/Group/interface';
	import Modal from '$lib/Generic/Modal.svelte';
	import { userStore } from '$lib/User/interfaces';
	import { workgroupStore } from '../Kanban/Kanban';
	import { chatPartnerStore } from '$lib/Chat/functions';

	export let workGroup: WorkGroup,
		workGroups: WorkGroup[],
		handleRemoveGroup: (id: number) => void,
		getWorkGroupInvite: () => {};

	let workGroupUserList: WorkGroupUser[] = [],
		showDeleteModal = false;

	const joinWorkGroup = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/workgroup/${workGroup.id}/join`
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to join Group',
				success: false
			});
			return;
		}

		workGroup.member_count++;
		workGroup.joined = true;
		workGroups = workGroups;
		workgroupStore.set(workGroups);
	};

	const askToJoin = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/workgroup/${workGroup.id}/join`
		);

		if (!res.ok) {
			const message =
				json?.detail?.__all__[0].toString() ===
				'Work group user join request with this Work group and Group user already exists.'
					? 'Already asked to join group'
					: 'Failed to ask to join group';

			ErrorHandlerStore.set({ message, success: false });
			return;
		}

		if (!res.ok) return;

		ErrorHandlerStore.set({ message: 'Invite Sent', success: true });
		workGroup.requested_access = true;
		getWorkGroupInvite();
	};

	const leaveWorkGroup = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/workgroup/${workGroup.id}/leave`
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to leave Group',
				success: false
			});
			return;
		}
		workGroupUserList = workGroupUserList.filter(
			(user) => user.id === ($userStore?.id || -1)
		);

		workGroup.member_count--;
		workGroup.joined = false;
		workGroup.requested_access = false;
		workgroupStore.set(workGroups);
		chatPartnerStore.set(0);
	};

	const deleteWorkGroup = async () => {
		showDeleteModal = false;
		const { res, json } = await fetchRequest(
			'POST',
			`group/workgroup/${workGroup.id}/delete`
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to delete workgroup',
				success: false
			});
			return;
		} else {
			ErrorHandlerStore.set({ message: 'Workgroup deleted', success: true });
		}

		handleRemoveGroup(workGroup.id);
		showDeleteModal = false;
		chatPartnerStore.set(0);
	};
</script>

<div
	class="dark:text-darkmodeText w-full px-4 py-2 flex justify-between items-center min-h-14"
	id={workGroup.name}
>
	<span
		class="text-primary dark:text-secondary w-[40%] font-semibold break-words"
		>{workGroup.name}</span
	>
	<span class="text-gray-500 text-sm w-[30%]"
		>{$_('Members')}: {workGroup.member_count || 0}
	</span>

	{#if workGroup.joined}
		<Button
			buttonStyle="warning-light"
			Class="px-3 py-1 w-[20%]"
			onClick={leaveWorkGroup}>{$_('Leave')}</Button
		>
	{:else if workGroup.direct_join}
		<Button
			buttonStyle="primary-light"
			Class="px-3 py-1 w-[20%]"
			onClick={joinWorkGroup}>{$_('Join')}</Button
		>
	{:else if !workGroup.requested_access}
		<Button
			buttonStyle="primary-light"
			Class="px-3 py-1 w-[20%]"
			onClick={askToJoin}>{$_('Ask to join')}</Button
		>
	{:else if workGroup.requested_access}
		<div Class="px-3 py-1 w-[20%]">{$_('Pending')}</div>
	{/if}

	{#if $groupUserStore?.is_admin}
		<Button
			buttonStyle="warning-light"
			Class="!border-0"
			onClick={() => (showDeleteModal = true)}><Fa icon={faTrash} /></Button
		>
	{/if}
</div>

<Modal
	bind:open={showDeleteModal}
	Class="max-w-[500px]"
	buttons={[
		{ label: 'Delete', type: 'warning', onClick: deleteWorkGroup },
		{
			label: 'Cancel',
			type: 'default',
			onClick: () => (showDeleteModal = false)
		}
	]}
>
	<div slot="body">
		<h2 class="text-xl font-semibold mb-4">{$_('Confirm Deletion')}</h2>
		<p class="mb-6">{$_('Are you sure you want to delete this workgroup?')}</p>
	</div>
</Modal>

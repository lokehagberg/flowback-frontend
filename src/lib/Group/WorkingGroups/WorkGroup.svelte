<script lang="ts">
	import { page } from '$app/stores';
	import type { WorkGroup, WorkGroupUser } from './interface';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { poppup } from '$lib/Generic/Poppup';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faTrash } from '@fortawesome/free-solid-svg-icons';
	import { getUserIsGroupAdmin } from '$lib/Generic/GenericFunctions';

	export let workGroup: WorkGroup,
		handleRemoveGroup: (id: number) => void,
		isAdmin = false;

	let poppup: poppup,
		workGroupUserList: WorkGroupUser[] = [];

	const getUserList = async () => {
		const { res, json } = await fetchRequest('GET', `group/workgroup/${workGroup.id}/list`);

		if (!res.ok) {
			workGroupUserList = workGroupUserList;
			// poppup = { message: 'Failed to get members in workgroup', success: false };
			return;
		}

		workGroupUserList = json.results;
	};

	const joinGroup = async () => {
		const { res, json } = await fetchRequest('POST', `group/workgroup/${workGroup.id}/join`);

		if (!res.ok) {
			poppup = { message: 'Failed to join Group', success: false };
			return;
		}

		// await getUserList();
	};

	const askToJoin = async () => {
		const { res, json } = await fetchRequest('POST', `group/workgroup/${workGroup.id}/join`);

		if (!res.ok) {
			const message =
				json?.detail?.__all__[0].toString() ===
				'Work group user join request with this Work group and Group user already exists.'
					? 'Already asked to join group'
					: 'Failed to ask to join group';

			poppup = { message, success: false };
			return;
		}

		poppup = { message: 'Invite Sent', success: true };
	};

	const leaveGroup = async () => {
		const { res, json } = await fetchRequest('POST', `group/workgroup/${workGroup.id}/leave`);

		if (!res.ok) {
			poppup = { message: 'Failed to Leave Group', success: false };
			return;
		}
		workGroupUserList = workGroupUserList.filter(
			(user) => user.id === Number(localStorage.getItem('userId'))
		);
		// getUserList();
	};

	const isMember = () => {
		return workGroupUserList.find(
			(user) => user.group_user.user.id === (Number(localStorage.getItem('userId')) || -1)
		);
	};

	const deleteWorkGroup = async () => {
		const { res, json } = await fetchRequest('POST', `group/workgroup/${workGroup.id}/delete`);

		if (!res.ok) {
			poppup = { message: 'Failed to delete workgroup', success: false };
			return;
		} else {
			poppup = { message: 'Workgroup deleted', success: true };
		}

		handleRemoveGroup(workGroup.id);
	};

	onMount(async () => {
		// getUserList();
	});
</script>

<div
	class="bg-white w-full px-4 py-2 flex justify-between items-center shadow rounded dark:bg-darkobject min-h-14"
>
	<span class="text-primary dark:text-secondary w-[40%] font-semibold break-words"
		>{workGroup.name}</span
	>
	<span class="text-gray-500 text-sm w-[30%]">{$_('Members')}: {workGroup.member_count} </span>

	{#if workGroup.joined}
		<Button buttonStyle="warning-light" Class="px-3 py-1 w-[20%]" action={leaveGroup}
			>{$_('Leave')}</Button
		>
	{:else if workGroup.direct_join}
		<Button buttonStyle="primary-light" Class="px-3 py-1 w-[20%]" action={joinGroup}
			>{$_('Join')}</Button
		>
	{:else}
		<Button buttonStyle="primary-light" Class="px-3 py-1 w-[20%]" action={askToJoin}
			>{$_('Ask to join')}</Button
		>
	{/if}

	{#if isAdmin}
		<Button buttonStyle="warning-light" action={deleteWorkGroup}><Fa icon={faTrash} /></Button>
	{/if}
</div>

<Poppup bind:poppup />

<script lang="ts">
	import type { WorkGroup, WorkGroupUser } from './interface';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { poppup } from '$lib/Generic/Poppup';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import { onMount } from 'svelte';

	export let workGroup: WorkGroup;

	let poppup: poppup,
		workGroupUserList: WorkGroupUser[] = [];

	const getUserList = async () => {
		const { res, json } = await fetchRequest('GET', `group/workgroup/${workGroup.id}/list`);

		if (!res.ok) {
			poppup = { message: 'Failed to get Work Group', success: false };
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

		await getUserList();
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

		getUserList();
	};

	const isMember = () => {
		return workGroupUserList.find(
			(user) => user.group_user.user.id === (Number(localStorage.getItem('userId')) || -1)
		);
	};

	onMount(() => {
		getUserList();
	});
</script>

<div class="bg-white w-full px-4 py-2 flex justify-between items-center shadow rounded dark:bg-darkobject min-h-14">
	<span class="text-primary w-[40%] font-bold">{workGroup.name}</span>
	<span class="text-gray-500 text-sm w-[30%]">Members: {workGroupUserList.length} </span>

	{#key workGroupUserList}
		{#if isMember()}
			<Button buttonStyle="warning" Class="px-3 py-1 w-[20%]" action={leaveGroup}>Leave</Button>
		{:else if workGroup.direct_join}
			<Button buttonStyle="primary-light" Class="px-3 py-1 w-[20%]" action={joinGroup}>Join</Button>
		{:else}
			<Button buttonStyle="primary-light" Class="px-3 py-1 w-[20%]" action={askToJoin}
				>Ask to Join</Button
			>
		{/if}
	{/key}
</div>

<Poppup bind:poppup />

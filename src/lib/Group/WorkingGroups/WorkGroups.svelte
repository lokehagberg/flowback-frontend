<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { WorkGroupInvite, WorkGroup as WorkingGroupType } from './interface';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import WorkingGroup from './WorkGroup.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';
	import { _ } from 'svelte-i18n';
	import { getUserIsGroupAdmin } from '$lib/Generic/GenericFunctions';
	import Loader from '$lib/Generic/Loader.svelte';

	let workGroups: WorkingGroupType[] = [],
		workGroupEdit: WorkingGroupType = {
			direct_join: false,
			members: null,
			name: '',
			id: 0,
			work_group_id: 0
		},
		poppup: poppup,
		open = false,
		search: string,
		invites: WorkGroupInvite[] = [],
		isAdmin = false,
		loading = true;

	const getWorkingGroupList = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/list?limit=100&name__icontains=${search}&order_by=name_desc`
		);

		if (!res.ok) {
			poppup = { message: 'Could not fetch work groups', success: false };
			return;
		}

		workGroups = json.results;
	};

	const createWorkingGroup = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/workgroup/create`,
			workGroupEdit
		);

		if (!res.ok) {
			poppup = { message: 'Failed to create work group', success: false };
			return;
		}

		await getWorkingGroupList();
		open = false;
	};

	const getWorkGroupInvite = async () => {
		workGroups.forEach(async (workGroup) => {
			const { res, json } = await fetchRequest(
				'GET',
				`group/workgroup/${workGroup.id}/joinrequest/list`
			);

			if (!res.ok) return;

			if (json.results[0]) invites.push(json.results[0]);
			invites = invites;
		});
	};

	const addUserToGroup = async (groupUserId: number, workGroupId: number) => {
		const { res, json } = await fetchRequest('POST', `group/workgroup/${workGroupId}/user/add`, {
			is_moderator: false,
			target_group_user_id: groupUserId
		});
	};

	onMount(async () => {
		loading = true;
		await getWorkingGroupList();
		getWorkGroupInvite();
		isAdmin = await getUserIsGroupAdmin($page.params.groupId);
		loading = false;
	});
</script>

<div class="bg-white dark:bg-darkobject p-6 shadow rounded mb-4">
	<TextInput
		label=""
		placeholder="search work group"
		bind:value={search}
		onInput={getWorkingGroupList}
	/>
</div>

<Button action={() => (open = true)} Class="p-2">{$_('Create work group')}</Button>

<Loader bind:loading>
	<div class="flex flex-col gap-4 mt-4">
		{#if isAdmin}
			{#key invites}
				{#each invites as invite}
					<div
						class="bg-white w-full px-4 py-2 flex gap-2 shadow rounded dark:bg-darkobject min-h-14"
					>
						<div class="flex justify-between w-full">
							<div>
								<b class="font-semibold">{invite.group_user.user.username}</b>
								{$_('wants to join')} <b class="font-semibold">{invite.work_group_name}</b>
							</div>
							<Button
								buttonStyle="primary-light"
								action={() => addUserToGroup(invite.group_user.id, invite.work_group_id)}
								>{$_('Add User')}</Button
							>
						</div>
					</div>
				{/each}
			{/key}
		{/if}
	</div>
	<div class="flex flex-col gap-4 mt-4">
		{#each workGroups as workingGroup}
			<WorkingGroup bind:workGroup={workingGroup} />
		{/each}
	</div>
</Loader>

<Poppup bind:poppup />

<Modal bind:open>
	<div slot="header" class="w-full"><span>{$_('Create work group')}</span></div>
	<form slot="body" class="w-full" on:submit|preventDefault={createWorkingGroup}>
		<TextInput label="Name" required bind:value={workGroupEdit.name} />

		<RadioButtons2
			bind:value={workGroupEdit.direct_join}
			values={[true, false]}
			labels={['Yes', 'No']}
			label="Direct Join?"
			name="direct_join"
		/>
		<Button Class="px-2" type="submit">{$_('Create')}</Button>
	</form>
</Modal>

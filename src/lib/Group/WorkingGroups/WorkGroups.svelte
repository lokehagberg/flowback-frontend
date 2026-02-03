<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import {
		type WorkGroupInvite,
		type WorkGroup as WorkingGroupType
	} from './interface';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import WorkingGroup from './WorkGroup.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';
	import { _ } from 'svelte-i18n';
	import { groupUserStore } from '$lib/Group/interface';
	import Loader from '$lib/Generic/Loader.svelte';

	let workGroups: WorkingGroupType[] = [],
		workGroupEdit: WorkingGroupType = {
			direct_join: false,
			members: null,
			name: '',
			id: 0,
			work_group_id: 0,
			member_count: 0,
			next: '',
			previous: '',
			total_page: 0,
			joined: false,
			chat: 1,
			requested_access: false
		},
		open = false,
		search: string,
		invites: WorkGroupInvite[] = [],
		loading = true;

	const getWorkingGroupList = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/list?limit=100&name__icontains=${search}&order_by=name_asc`
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Could not fetch work groups',
				success: false
			});
			return;
		}

		workGroups = json?.results;
	};

	const createWorkGroup = async () => {
		workGroupEdit.chat = 1;
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/workgroup/create`,
			workGroupEdit
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to create work group',
				success: false
			});
			return;
		}

		await getWorkingGroupList();

		workGroupEdit = {
			direct_join: true,
			members: null,
			name: '',
			id: 0,
			work_group_id: 0,
			member_count: 0,
			next: '',
			previous: '',
			total_page: 0,
			joined: false,
			chat: 1,
			requested_access: false
		};

		open = false;
	};

	const getWorkGroupInvite = async () => {
		invites = [];

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/workgroup/joinrequest/list`
		);

		if (!res.ok) return;

		invites = json.results;
	};

	const addUserToGroup = async (groupUserId: number, workGroupId: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/workgroup/${workGroupId}/user/add`,
			{
				is_moderator: false,
				target_group_user_id: groupUserId
			}
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to add user to group',
				success: false
			});
			return;
		}

		invites = invites.filter((invite) => invite.work_group_id !== workGroupId);

		let workGroup = workGroups.find(
			(workGroup) => workGroup.id === workGroupId
		);
		if (workGroup) {
			workGroup.requested_access = false;
			workGroup.member_count++;
			workGroup.joined = true;
		}

		workGroups = workGroups;
	};

	const handleRemoveGroup = (id: number) => {
		workGroups = workGroups.filter((group) => group.id !== id);
		getWorkGroupInvite();
	};

	onMount(async () => {
		loading = true;
		await getWorkingGroupList();

		getWorkGroupInvite();
		loading = false;
	});
</script>

<div class="flex items-center gap-4 mb-2">
	<div
		class="bg-white text-black dark:text-darkmodeText dark:bg-darkobject p-4 shadow rounded flex-1 flex flex-col gap-2"
	>
		<span class="text-sm"
			>{$_(
				`Being a part of a work group means that you will join that work group's chat, have access to viewing and creating tasks, events, and posts assigned to that work group. Work groups have no individual pages.`
			)}</span
		>
		<TextInput
			label=""
			max={null}
			search={true}
			placeholder={$_('Search work groups')}
			bind:value={search}
			onInput={getWorkingGroupList}
		/>
	</div>
</div>

<Loader bind:loading>
	{#if $groupUserStore?.is_admin && invites?.length > 0}
		<div
			class="bg-white shadow rounded flex flex-col dark:bg-darkobject gap-4 dark:text-darkmodeText"
		>
			{#each invites as invite}
				<div class="w-full px-4 py-2 flex gap-2 min-h-14">
					<div class="flex justify-between w-full">
						<div>
							<b class="font-semibold">{invite.group_user.user.username}</b>
							{$_('wants to join')}
							<b class="font-semibold">{invite.work_group_name}</b>
						</div>
						<Button
							buttonStyle="primary-light"
							onClick={() =>
								addUserToGroup(invite.group_user.id, invite.work_group_id)}
							>{$_('Add User')}</Button
						>
					</div>
				</div>
			{/each}
		</div>
	{/if}

	{#if $groupUserStore?.is_admin}
		<button
			on:click={() => (open = true)}
			class="mt-2 text-left bg-white hover:bg-gray-100 cursor-pointer active:bg-gray-200 dark:bg-darkobject shadow rounded-sm dark:text-darkmodeText w-full px-4 py-2 flex justify-between items-center min-h-14"
		>
			<span
				class="text-primary dark:text-secondary w-[40%] font-semibold break-words"
				>{$_('+ Add Workgroup')}</span
			>
		</button>
	{/if}

	<div
		class="bg-white shadow rounded-sm dark:bg-darkobject flex flex-col gap-4 mt-2"
	>
		{#each workGroups as workingGroup}
			<WorkingGroup
				{getWorkGroupInvite}
				bind:workGroup={workingGroup}
				{workGroups}
				{handleRemoveGroup}
			/>
		{/each}
	</div>
</Loader>

<Modal
	bind:open
	Class="max-w-[500px]"
	buttons={[
		{ label: 'Create', type: 'primary', onClick: createWorkGroup },
		{ label: 'Cancel', type: 'default', onClick: () => (open = false) }
	]}
>
	<div slot="header" class="w-full"><span>{$_('Create work group')}</span></div>
	<form slot="body" class="w-full" on:submit|preventDefault={createWorkGroup}>
		<TextInput label="Name" required bind:value={workGroupEdit.name} />

		<RadioButtons2
			bind:value={workGroupEdit.direct_join}
			values={[true, false]}
			labels={['Yes', 'No']}
			label="Direct Join?"
			name="direct_join"
		/>
	</form>
</Modal>

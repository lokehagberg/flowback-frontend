<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Toggle from '$lib/Generic/Toggle.svelte';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { _ } from 'svelte-i18n';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import { onDestroy, onMount } from 'svelte';
	import type { Permissions } from './interface';

	export let selectedRole: any, selectedPage: 'assign' | 'create' | 'list';

	const perms = [
		{
			title: 'Invite',
			description: 'Allows user to invite other people in the invitation tab'
		},
		{ title: 'Create post', description: 'Allows user to create posts' },
		{
			title: 'Voting rights',
			description: 'Allows user to vote on proposals in polls'
		},
		{
			title: 'Kick users',
			description: 'Allows user to kick users from the group'
		},
		{ title: 'Ban users', description: 'Allows user to ban users from the group' },
		{
			title: 'Fast Forward Poll',
			description: 'Allows user to fast forward polls'
		},
		{
			title: 'Create Proposal',
			description: 'Allows user to create proposals in polls during proposal phase'
		},
		{
			title: 'Update Proposal',
			description: 'Allows user to change any proposal in a poll'
		},
		{
			title: 'Delete Proposal',
			description: 'Allows user to remove any proposal in a poll'
		},
		{ title: 'Delete Poll', description: 'Allows user to delete any poll' },
		{ title: 'Force Delete Proposal', description: 'Allows user to delete any proposal' },
		{ title: 'Delete Comment', description: 'Allows user to delete any comment' },
		{
			title: 'Create Consequence',
			description: 'Allows user to create consequences in polls'
		},
		{
			title: 'Delete Consequence',
			description: 'Allows user to delete consequences in polls'
		},
		{
			title: 'Create Consequence Probability',
			description: 'Allows user to create consequence probabilities in polls'
		},
		{
			title: 'Update Consequence Probability',
			description: 'Allows user to modify consequence probabilities in polls'
		},
		{
			title: 'Delete Consequence Probability',
			description: 'Allows user to delete consequence probabilities in polls'
		}
	];

	let loading = false,
		roleName = '',
		rolePerms = new Array(perms.length).fill(false);

	const permissionCreate = async () => {
		loading = true;
		const { json, res } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/permission/create`,
			{
				role_name: roleName,
				invite_user: rolePerms[0],
				create_poll: rolePerms[1],
				allow_vote: rolePerms[2],
				kick_members: rolePerms[3],
				ban_members: rolePerms[4],
				poll_fast_forward: rolePerms[5],
				create_proposal: rolePerms[6],
				update_proposal: rolePerms[7],
				delete_proposal: rolePerms[8],
				force_delete_poll: rolePerms[9],
				force_delete_proposal: rolePerms[10],
				force_delete_comment: rolePerms[11],
				prediction_statement_create: rolePerms[12],
				prediction_statement_delete: rolePerms[13],
				prediction_bet_create: rolePerms[14],
				prediction_bet_update: rolePerms[15],
				prediction_bet_delete: rolePerms[16]
			}
		);

		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Could not create role', success: false });
			return;
		}

		roleName = '';
		for (let i = 0; i < rolePerms.length; i++) {
			rolePerms[i] = false;
		}

		ErrorHandlerStore.set({ message: 'Successfully created role', success: true });

	};

	const permissionUpdate = async () => {
		loading = true;
		const { json, res } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/permission/update`,
			{
				permission_id: selectedRole.id,
				role_name: roleName,
				invite_user: rolePerms[0],
				create_poll: rolePerms[1],
				allow_vote: rolePerms[2],
				kick_members: rolePerms[3],
				ban_members: rolePerms[4],
				poll_fast_forward: rolePerms[5],
				create_proposal: rolePerms[6],
				update_proposal: rolePerms[7],
				delete_proposal: rolePerms[8],
				force_delete_poll: rolePerms[9],
				force_delete_proposal: rolePerms[10],
				force_delete_comment: rolePerms[11],
				prediction_statement_create: rolePerms[12],
				prediction_statement_delete: rolePerms[13],
				prediction_bet_create: rolePerms[14],
				prediction_bet_update: rolePerms[15],
				prediction_bet_delete: rolePerms[16]
			}
		);

		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Could not update role', success: false });
			return;
		}

		ErrorHandlerStore.set({ message: 'Successfully updated role', success: true });
		selectedRole = undefined;
	};

	const transformIntoRolePermType = (permissions: Permissions) => {
		//TODO: Turn this into a for loop?
		roleName = permissions.role_name;
		rolePerms[0] = permissions.invite_user;
		rolePerms[1] = permissions.create_poll;
		rolePerms[2] = permissions.allow_vote;
		rolePerms[3] = permissions.kick_members;
		rolePerms[4] = permissions.ban_members;
		rolePerms[5] = permissions.poll_fast_forward;
		rolePerms[6] = permissions.create_proposal;
		rolePerms[7] = permissions.update_proposal;
		rolePerms[8] = permissions.delete_proposal;
		rolePerms[9] = permissions.force_delete_poll;
		rolePerms[10] = permissions.force_delete_proposal;
		rolePerms[11] = permissions.force_delete_comment;
		rolePerms[12] = permissions.prediction_statement_create;
		rolePerms[13] = permissions.prediction_statement_delete;
		rolePerms[14] = permissions.prediction_bet_create;
		rolePerms[15] = permissions.prediction_bet_update;
		rolePerms[16] = permissions.prediction_bet_delete;
	};

	onMount(() => {
		if (selectedRole) transformIntoRolePermType(selectedRole);
	});

	onDestroy(() => {
		roleName = '';
		selectedRole = undefined;
	});
</script>

<Loader bind:loading>
	<div class="p-6 rounded">
		<form
			class="flex flex-col gap-4"
			on:submit|preventDefault={() => (selectedRole ? permissionUpdate() : permissionCreate())}
		>
			<TextInput label={$_('Role name')} bind:value={roleName} required />
			<h1 class="text-xl">{$_('Permissions')}</h1>
			{#each perms as perm, i}
				<div class="flex justify-between">
					<details>
						<summary>{$_(perm.title)}</summary>
						{$_(perm.description)}
					</details>
					<Toggle bind:checked={rolePerms[i]} />
				</div>
			{/each}
			{#if selectedRole}
				<Button type="submit">{$_('Edit Role')}</Button>
			{:else}
				<Button type="submit">{$_('Create Role')}</Button>
			{/if}
		</form>
	</div>
</Loader>

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Toggle from '$lib/Generic/Toggle.svelte';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import Loader from '$lib/Generic/Loader.svelte';
	import { _ } from 'svelte-i18n';

	let status: StatusMessageInfo,
		loading = false;

	const perms = [
		{
			title: $_('Invite'),
			description: $_('Allows user to invite other people in the invitation tab')
		},
		{ title: $_('Create poll'), description: $_('Allows user to create polls') },
		{
			title: $_('Voting rights'),
			description: $_('Allows user to vote on proposals in polls')
		},
		{
			title: $_('Kick users'),
			description: $_('Allows user to kick users from the group')
		},
		{ title: $_('Ban users'), description: $_('Allows user to ban users from the group') },
		{
			title: $_('Fast Forward Poll'),
			description: $_('Allows user to change timeline phase on a poll')
		},
		{
			title: $_('Create Proposal'),
			description: $_('Allows user to create proposals in polls during proposal phase')
		},
		{
			title: $_('Update Proposal'),
			description: $_('Allows user to change any proposal in a poll')
		},
		{
			title: $_('Delete Proposal'),
			description: $_('Allows user to remove any proposal in a poll')
		},
		{ title: $_('Delete Poll'), description: $_('Allows user to delete any poll') },
		{ title: $_('Delete Proposal'), description: $_('Allows user to delete any proposal') },
		{ title: $_('Delete Comment'), description: $_('Allows user to delete any comment') },
		{ title: $_('prediction_statement_create'), description: '' },
		{ title: $_('prediction_statement_delete'), description: '' },
		{ title: $_('prediction_bet_create'), description: '' },
		{ title: $_('prediction_bet_update'), description: '' },
		{ title: $_('prediction_bet_delete'), description: '' }
	];

	let roleName = '';
	let rolePerms = new Array(perms.length).fill(false);

	const createRole = async () => {
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
		status = statusMessageFormatter(res, json, $_('Successfully created role'));
	};
</script>

<Loader bind:loading>
	<div class="p-6 rounded">
		<form class="flex flex-col gap-4" on:submit|preventDefault={createRole}>
			<TextInput label={$_('Role name')} bind:value={roleName} required />
			<h1 class="text-xl">{$_('Permissions')}</h1>
			{#each perms as perm, i}
				<div class="flex justify-between">
					<details>
						<summary>{perm.title}</summary>
						{perm.description}
					</details>
					<Toggle bind:checked={rolePerms[i]} />
				</div>
			{/each}
			<StatusMessage bind:status />
			<Button type="submit">{$_('Create Role')}</Button>
		</form>
	</div>
</Loader>

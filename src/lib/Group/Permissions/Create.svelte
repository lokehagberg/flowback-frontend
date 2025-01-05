<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Toggle from '$lib/Generic/Toggle.svelte';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { _ } from 'svelte-i18n';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';

	let loading = false,
		poppup: poppup;

	const perms = [
		{
			title: 'Invite',
			description: 'Allows user to invite other people in the invitation tab'
		},
		{ title: 'Create poll', description: 'Allows user to create polls' },
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
			description: 'Allows user to change timeline phase on a poll'
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
			title: 'Create Prediction Statement',
			description: 'Allows user to create prediction statements in polls'
		},
		{
			title: 'Delete Prediction Statement',
			description: 'Allows user to delete prediction statements in polls'
		},
		{
			title: 'Create Prediction Bet',
			description: 'Allows user to create prediction bets in polls'
		},
		{
			title: 'Update Prediction Bet',
			description: 'Allows user to modify prediction bets in polls'
		},
		{
			title: 'Delete Prediction Bet',
			description: 'Allows user to delete prediction bets in polls'
		}
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

		if (!res.ok) {
			poppup = { message: 'Could not create role', success: false };
			return;
		}
		poppup = { message: 'Successfully created role', success: true };
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
						<summary>{$_(perm.title)}</summary>
						{$_(perm.description)}
					</details>
					<Toggle bind:checked={rolePerms[i]} />
				</div>
			{/each}
			<Button type="submit">{$_('Create Role')}</Button>
		</form>
	</div>
</Loader>

<Poppup bind:poppup />

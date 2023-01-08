<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import Toggle from '$lib/Generic/Toggle.svelte';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';

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
		{ title: 'Ban users', description: 'Allows user to ban users from the group' }
	];

	let roleName = '';
	let rolePerms = [false, false, false, false, false];

	const createRole = () => {
		fetchRequest('POST', `group/${$page.params.groupId}/permission/create`, {
			role_name: roleName,
			invite_user: rolePerms[0],
			create_poll: rolePerms[1],
			allow_vote: rolePerms[2],
			kick_members: rolePerms[3],
			ban_members: rolePerms[4]
		});
	};
</script>

<div class="bg-white p-6 rounded">
	<form class="flex flex-col gap-4" on:submit|preventDefault={createRole}>
		<TextInput label="Role name" bind:value={roleName} />
		<h1 class="text-xl">Permissions</h1>
		{#each perms as perm, i}
			<div class="flex justify-between">
				<details>
					<summary>{perm.title}</summary>
					{perm.description}
				</details>
				<Toggle bind:checked={rolePerms[i]} />
			</div>
		{/each}
		<ButtonPrimary type="submit">Create Role</ButtonPrimary>
	</form>
</div>

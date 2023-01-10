<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { Permission } from './interface';
	import { onMount } from 'svelte';
	import Role from './Role.svelte';

	let roles: Permission[] = [];

	const getRoleList = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/permissions?limit=100`
		);
		roles = json.results;
	};

	onMount(() => {
		getRoleList();
	});
</script>

<table class="w-full">
    <tr class="">
        <th>Name</th>
        <th>Invite</th>
        <th>Poll creation</th>
        <th>Voting</th>
        <th>Kick</th>
        <th>Ban</th>
    </tr>
	{#each roles as role}
		<tr class="">
            <th>{role.role_name}</th>
            <Role role={role.invite_user}/>
            <Role role={role.create_poll}/>
            <Role role={role.allow_vote}/>
            <Role role={role.kick_members}/>
            <Role role={role.ban_members}/>
		</tr>
	{/each}
</table>

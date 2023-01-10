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

<div>
    <div class="flex justify-around">
        <div>Invite</div>
        <div>Poll creation</div>
        <div>Voting</div>
        <div>Kick</div>
        <div>Ban</div>
    </div>
	{#each roles as role}
		<div class="flex justify-around">
            <Role role={role.invite_user}/>
            <Role role={role.create_poll}/>
            <Role role={role.allow_vote}/>
            <Role role={role.kick_members}/>
            <Role role={role.ban_members}/>
		</div>
	{/each}
</div>

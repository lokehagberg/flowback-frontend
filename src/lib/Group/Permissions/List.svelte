<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { Permission } from './interface';
	import { onMount } from 'svelte';
	import Role from './Role.svelte';
	import { permissions as permissionsLimit } from '../../Generic/APILimits.json'
	import { _ } from 'svelte-i18n';
	
	let roles: Permission[] = [];

	const getRoleList = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/permissions?limit=${permissionsLimit}`
		);
		roles = json.results;
	};

	onMount(() => {
		getRoleList();
	});
</script>

<table class="w-full">
    <tr class="">
        <th>{$_('Name')}</th>
        <th>{$_('Invite')}</th>
        <th>{$_('Poll creation')}</th>
        <th>{$_('Voting')}</th>
        <th>{$_('Kick')}</th>
        <th>{$_('Ban')}</th>
    </tr>
	{#each roles as role}
		<tr class="font-light">
            <th>{role.role_name}</th>
            <Role role={role.invite_user}/>
            <Role role={role.create_poll}/>
            <Role role={role.allow_vote}/>
            <Role role={role.kick_members}/>
            <Role role={role.ban_members}/>
		</tr>
	{/each}
</table>

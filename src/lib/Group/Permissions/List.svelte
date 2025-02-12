<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { Permission } from './interface';
	import { onMount } from 'svelte';
	import Role from './Role.svelte';
	import { permissions as permissionsLimit } from '../../Generic/APILimits.json';
	import { _ } from 'svelte-i18n';

	export let selectedPage: 'assign' | 'create' | 'list';

	let roles: Permission[] = [],
		selectedRole: any;

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

<ul>
	{#each roles as role}
		<li>
			<button
				on:click={async () => {
					console.log(role, "RULE");
					
					selectedRole = role
					setTimeout(() => {
						selectedPage = 'create';

					}, 1000)
				}}>{role.role_name}</button
			>
		</li>
		<!-- <Role role={role.invite_user}/>
	<Role role={role.create_poll}/>
	<Role role={role.allow_vote}/>
	<Role role={role.kick_members}/>
	<Role role={role.ban_members}/> -->
	{/each}
</ul>

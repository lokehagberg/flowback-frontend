<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { Permission } from './interface';
	import { onMount } from 'svelte';
	import Role from './Role.svelte';
	import { permissions as permissionsLimit } from '../../Generic/APILimits.json';
	import { _ } from 'svelte-i18n';

	export let selectedPage: 'assign' | 'create' | 'list',
	selectedRole: any;

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
	{/each}
</ul>

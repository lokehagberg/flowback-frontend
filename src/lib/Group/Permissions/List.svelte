<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { Permission } from './interface';
	import { onMount } from 'svelte';
	import { permissions as permissionsLimit } from '../../Generic/APILimits.json';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faTrash } from '@fortawesome/free-solid-svg-icons';
	import Button from '$lib/Generic/Button.svelte';

	export let selectedPage: 'assign' | 'create' | 'list', selectedRole: any;

	let roles: Permission[] = [];

	const getRoleList = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/permissions?limit=${permissionsLimit}`
		);
		roles = json.results;
	};

	const deletePermission = async (permission_id: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/permission/delete`,
			{
				permission_id
			}
		);

		if (!res.ok) return;

		roles = roles.filter((role) => role.id !== permission_id);
	};

	onMount(() => {
		getRoleList();
	});
</script>

<ul class="flex flex-col gap-2 py-2">
	{#each roles as role}
		<li class="flex justify-between items-center">
			<button
				on:click={async () => {
					selectedRole = role;
					selectedPage = 'create';
				}}>{role.role_name}</button
			>
			<Button action={() => deletePermission(role.id)} Class="p-2 text-lg cursor-pointer bg-white">
				<Fa class="text-red-500" icon={faTrash} />
			</Button>
		</li>
	{/each}
</ul>

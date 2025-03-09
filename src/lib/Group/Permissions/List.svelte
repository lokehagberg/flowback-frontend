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

	let roles: Permission[] = [],
		showDeleteModal = false;

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
			<Button action={() => (showDeleteModal = true)} Class="p-2 text-lg cursor-pointer bg-white">
				<Fa class="text-red-500" icon={faTrash} />
			</Button>
		</li>

		{#if showDeleteModal}
			<div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
				<div class="bg-white dark:bg-darkobject p-6 rounded shadow-lg w-96">
					<h2 class="text-xl font-semibold mb-4">{$_('Confirm Deletion')}</h2>
					<p class="mb-6">{$_('Are you sure you want to delete this workgroup?')}</p>
					<div class="flex justify-end space-x-2">
						<Button buttonStyle="primary-light" action={() => (showDeleteModal = false)}>
							{$_('Cancel')}
						</Button>
						<Button
							buttonStyle="warning-light"
							action={() => {
								deletePermission(role.id);
								showDeleteModal = false;
							}}
						>
							{$_('Delete')}
						</Button>
					</div>
				</div>
			</div>
		{/if}
	{/each}
</ul>

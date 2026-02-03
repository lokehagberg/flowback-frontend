<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { Permissions } from './interface';
	import { onMount } from 'svelte';
	import { permissions as permissionsLimit } from '../../Generic/APILimits.json';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faTrash } from '@fortawesome/free-solid-svg-icons';
	import Button from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import type { Group } from '../interface';

	export let selectedPage: 'assign' | 'create' | 'list', selectedRole: any;

	let roles: Permissions[] = [],
		showDeleteModal = false,
		group: Group | undefined;

	const getRoleList = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/permissions?limit=${permissionsLimit}`
		);
		roles = json?.results;
	};

	const deletePermission = async (permission_id: number) => {
		showDeleteModal = false;
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

	// TODO: Make into a store that can be accessed anywhere in the group
	const getGroupInfo = async () => {
		const { res, json } = await fetchRequest('GET', `group/${$page.params.groupId}/detail`);
		if (!res.ok) return;
		return json;
	};

	onMount(async () => {
		getRoleList();
		group = await getGroupInfo();
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
			{#if role.id !== group?.default_permission}
				<Button
					onClick={() => (showDeleteModal = true)}
					Class="p-2 text-lg cursor-pointer bg-white dark:bg-darkobject"
					id={'delete-permission-button ' + role.role_name}
				>
					<Fa class="text-red-500" icon={faTrash} />
				</Button>
			{/if}
		</li>

		{#if showDeleteModal}
			<Modal
				bind:open={showDeleteModal}
				buttons={[
					{ label: 'Delete', type: 'warning', onClick: () => deletePermission(role.id) },
					{ label: 'Cancel', type: 'default', onClick: () => (showDeleteModal = false) }
				]}
			>
				<h2 slot="header">{$_('Confirm Deletion')}</h2>
				<p slot="body">{$_('Are you sure you want to delete this permission?')}</p>
			</Modal>
		{/if}
	{/each}
</ul>

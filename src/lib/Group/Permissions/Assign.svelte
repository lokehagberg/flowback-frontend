<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import type { GroupUser } from '../interface';
	import Tag from '../Tag.svelte';
	import Fa from 'svelte-fa';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import { onMount } from 'svelte';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { permissions as permissionsLimit } from '../../Generic/APILimits.json';
	import Button from '$lib/Generic/Button.svelte';
	import { idfy } from '$lib/Generic/GenericFunctions2';
	import { goto } from '$app/navigation';

	let roles: GroupUser[] = [],
		users: GroupUser[] = [];

	const getRoleList = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/permissions?limit=${permissionsLimit}`
		);
		roles = json?.results;
	};

	const getUsers = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?limit=${permissionsLimit}`
		);
		users = json?.results;
	};

	const updateUserRoles = async (roleId: number, userId: number, is_admin: boolean) => {
		const { json, res } = await fetchRequest('POST', `group/${$page.params.groupId}/user/update`, {
			target_user_id: userId,
			permission: roleId,
			is_admin
		});

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Failed to update permission', success: false });
			return;
		}

		ErrorHandlerStore.set({ message: 'Successfully updated permission', success: true });

		//@ts-ignore
		users.find((user) => user.user.id === userId)!.permission_name = roles.find(
			(role) => role.id === roleId
		)?.role_name;
		users = users;
	};

	const makeAdmin = async (user: GroupUser) => {
		const { json, res } = await fetchRequest('POST', `group/${$page.params.groupId}/user/update`, {
			target_user_id: user.user.id,
			is_admin: true
		});

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Failed to make user admin', success: false });
			return;
		}

		users.find((u) => u.user.id === user.user.id)!.is_admin = true;
		users = users;
		ErrorHandlerStore.set({ message: 'User is now admin', success: true });
	};

	onMount(() => {
		getUsers();
		getRoleList();
	});

	let selected: number;
</script>

<ul class="w-full">
	{#each users as user}
		<li class=" p-3 w-full border-b-2 border-gray-200">
			<div class="flex items-center">
				<button class="flex" on:click={() => goto(`/user?id=${user.user.id}`)}>
					<ProfilePicture
						username={user.user.username}
						profilePicture={user.user.profile_image}
						displayName
					/>
				</button>
				<div class="ml-6 flex gap-2 flex-wrap mt-4">
					<Tag
						Class="!cursor-default"
						tag={{ active: true, id: 1, name: user.permission_name }}
						displayImac={false}
					/>
					{#if user?.is_admin}
						<div class="bg-gray-300 px-2 py-0.5 rounded-lg dark:bg-gray-700 mr-2">
							{$_('Admin')}
						</div>
					{/if}
				</div>
				<button
					class:selected={selected === user.user.id}
					class="faPlus ml-auto cursor-pointer"
					on:click={() => (selected === user.user.id ? (selected = -1) : (selected = user.user.id))}
					id={`plus-${user.user.username}`}
				>
					<Fa icon={faPlus} size="lg" />
				</button>
				{#if !user.is_admin}
					<Button onClick={() => makeAdmin(user)}>{$_('Make admin')}</Button>
				{/if}
			</div>
			<div
				class="p-6 mt-6 shadow rounded border border-gray-200 z-50 right-5"
				class:hidden={selected !== user.user.id}
			>
				<h1 class="text-xl">{user.user.username}</h1>
				<!-- TODO: Add user search (and tag search too?) -->
				<!-- <TextInput label="Search" /> -->
				<ul class="mt-6 flex flex-wrap items-center">
					{#each roles as role}
						<li>
							<button
								class="w-full md:w-1/2 lg:w-1/3 xl:w-1/4"
								on:click={() => updateUserRoles(role.id, user.user.id, user.is_admin)}
							>
								<Tag
									tag={{ active: true, id: 1, name: role.role_name ?? '' }}
									Class={`${user.user.id === role.id ? 'bg-blue-300' : 'bg-blue-600'}`}
									displayImac={false}
									id={`permission-${idfy(role.role_name ?? '')}-${idfy(user.user.username)}`}
								/>
							</button>
						</li>
					{/each}
				</ul>
			</div>
		</li>
	{/each}
</ul>

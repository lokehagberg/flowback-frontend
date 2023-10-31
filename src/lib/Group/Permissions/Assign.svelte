<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { Permission } from './interface';
	import type { groupUser } from '../interface';
	import Tag from '../Tag.svelte';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import { onMount } from 'svelte';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { permissions as permissionsLimit } from '../../Generic/APILimits.json';

	let roles: Permission[] = [];
	let users: groupUser[] = [];

	const getRoleList = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/permissions?limit=${permissionsLimit}`
		);
		roles = json.results;
	};

	const getUsers = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?limit=${permissionsLimit}`
		);
		users = json.results;
	};

	const updateUserRoles = async (roleId: number) => {
		const { json } = await fetchRequest('POST', `group/${$page.params.groupId}/user/update`, {
			user: localStorage.getItem('userId'),
			permission: roleId
		});
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
				<div class="flex">
					<ProfilePicture user={user.user} displayName />
				</div>
				<div class="ml-6 flex gap-2 flex-wrap mt-4">
					<Tag tag={user.permission_name} />
				</div>
				<div
					class:selected={selected === user.id}
					class="faPlus ml-auto cursor-pointer"
					on:click={() => (selected === user.id ? (selected = -1) : (selected = user.id))}
					on:keydown
				>
					<Fa icon={faPlus} size="2x" />
				</div>
			</div>
			<div
				class="p-6 mt-6 shadow rounded border border-gray-200 z-50 right-5"
				class:hidden={selected !== user.id}
			>
				<h1 class="text-xl">{user.user.username}</h1>
				<!-- <TextInput label="Search" /> -->
				<ul class="mt-6 flex flex-wrap items-center">
					{#each roles as role}
						<li
							class="w-full md:w-1/2 lg:w-1/3 xl:w-1/4"
							on:click={() => updateUserRoles(role.id)}
							on:keydown
						>
							<Tag
								tag={role.role_name}
								Class={`cursor-pointer ${user.id === role.id ? 'bg-blue-300' : 'bg-blue-600'}`}
							/>
						</li>
					{/each}
				</ul>
			</div>
		</li>
	{/each}
</ul>

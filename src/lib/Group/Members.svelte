<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { userStore } from '$lib/User/interfaces';
	import Loader from '$lib/Generic/Loader.svelte';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { groupUserStore, type GroupUser, type User } from './interface';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faEnvelope } from '@fortawesome/free-solid-svg-icons/faEnvelope';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { groupMembers as groupMembersLimit } from '$lib/Generic/APILimits.json';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import { env } from '$env/dynamic/public';
	import { faPaperPlane, faRunning } from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import Button from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { chatPartnerStore, chatOpenStore } from '$lib/Chat/functions';
	import Select from '$lib/Generic/Select.svelte';
	import { getUserChannelId } from '$lib/Chat/functions';
	import UserSearch from '$lib/Generic/UserSearch.svelte';
	import type { Permissions } from './Permissions/interface';

	let users: GroupUser[] = [],
		usersAskingForInvite: any[] = [],
		loading = true,
		searchUserQuery = '',
		searchInvitationQuery = '',
		searchedInvitationUsers: User[] = [],
		searchedUsers: GroupUser[] = [],
		searched = false,
		removeUserModalShow = false,
		adminFilter: 'All' | 'Admin' | 'Member' = 'All',
		permissions: Permissions[] = [],
		roleFilter: number | null = null;

	let sortOrder: 'a-z' | 'z-a' = 'a-z'; // Default to a-z sort

	onMount(async () => {
		getUsers();
		getInvitesList();
		searchUsers('');
		getPermissions();
		//Does this one even do anything?
		// fetchRequest('GET', `group/${$page.params.groupId}/invites`);
	});

	const getUsers = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?limit=${groupMembersLimit}&is_admin=${adminFilter}`
		);
		users = json?.results;
		loading = false;
	};

	const searchUsers = async (username: string) => {
		let query = `?limit=${groupMembersLimit}&username__icontains=${username}`;

		if (adminFilter === 'Admin') query += '&is_admin=true';
		else if (adminFilter === 'Member') query += '&is_admin=false';

		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?limit=${groupMembersLimit}&username__icontains=${username}`
		);

		searchedUsers = json?.results;

		// Apply sorting based on sortOrder (always sort)
		if (sortOrder === 'a-z') {
			searchedUsers = searchedUsers.sort((a, b) =>
				a.user.username
					.toLowerCase()
					.localeCompare(b.user.username.toLowerCase())
			);
		} else if (sortOrder === 'z-a') {
			searchedUsers = searchedUsers.sort((a, b) =>
				b.user.username
					.toLowerCase()
					.localeCompare(a.user.username.toLowerCase())
			);
		}
	};

	const getInvitesList = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/invites`
		);
		if (res.ok) usersAskingForInvite = json?.results;
		// else poppup = { message: "Couldn't get invites list", success: false };
	};

	const inviteUser = async (userId: number) => {
		loading = true;
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/invite`,
			{
				to: userId
			}
		);

		loading = false;
		if (!res.ok) {
			ErrorHandlerStore.set({
				message: "Couldn't get invites list",
				success: false
			});
			return;
		}

		ErrorHandlerStore.set({
			success: true,
			message: 'Successfully sent invite'
		});

		searchInvitationQuery = '';
		searchedInvitationUsers = [];
	};

	const acceptInviteUser = async (userId: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/invite/accept`,
			{
				to: userId
			}
		);

		usersAskingForInvite = usersAskingForInvite.filter(
			(user) => user.id !== userId
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: "Couldn't accept user invite",
				success: false
			});
			return;
		}

		await getInvitesList();
		await getUsers();
		await searchUsers(searchUserQuery);
	};

	const denyInviteUser = async (userId: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/invite/reject`,
			{
				to: userId
			}
		);
		if (!res.ok) {
			ErrorHandlerStore.set({
				message: "Couldn't reject user invite",
				success: false
			});
			return;
		}

		usersAskingForInvite = usersAskingForInvite.filter(
			(user) => user.id !== userId
		);
		await getInvitesList();
	};

	const userRemove = async (userToRemove: number) => {
		const { res } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/user/delete`,
			{
				target_user_id: userToRemove
			}
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: $_('Failed to remove user'),
				success: false
			});
			return;
		}

		ErrorHandlerStore.set({
			message: $_('Successfully removed user'),
			success: true
		});
		searchedUsers = searchedUsers.filter(
			(user) => user.user.id !== userToRemove
		);
		removeUserModalShow = false;
		await getUsers();
	};

	const resetFilter = () => {
		sortOrder = 'a-z'; // Reset to default a-z sort instead of null
		searchUsers(searchUserQuery);
	};

	const getPermissions = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/permissions?limit=1000`
		);
		if (!res.ok) return;
		permissions = json.results;
	};
</script>

<Loader bind:loading>
	<div
		class="flex flex-col items-center gap-2 mb-24 relative dark:bg-darkobject dark:text-darkmodeText pb-2"
	>
		<!-- Search in Members list -->
		<div class="flex items-center gap-3 w-full">
			<form
				class="bg-white dark:bg-darkobject dark:text-darkmodeText shadow rounded p-4 flex flex-1 items-end gap-4"
				on:input|preventDefault={() => searchUsers(searchUserQuery)}
			>
				<div class="flex-col w-full">
					<TextInput
						Class="w-full"
						onInput={() => (searched = false)}
						label=""
						max={null}
						search={true}
						placeholder={$_('Search members')}
						bind:value={searchUserQuery}
					/>

					<div class="flex flex-row items-center gap-1 pt-2">
						<span>{$_('Sort')}: </span>
						<Select
							classInner="p-1 font-semibold"
							labels={[$_('A - Z'), $_('Z - A')]}
							values={['a-z', 'z-a']}
							bind:value={sortOrder}
							onInput={() => searchUsers(searchUserQuery)}
						/>

						<span class="pl-4">{$_('Role')}: </span>
						<Select
							classInner="p-1 font-semibold"
							labels={[$_('All'), $_('Admin'), $_('Member')]}
							values={['All', 'Admin', 'Member']}
							bind:value={adminFilter}
							onInput={() => searchUsers(searchUserQuery)}
							disableFirstChoice
						/>

						<span class="pl-4">{$_('Role')}: </span>
						<Select
							classInner="p-1 font-semibold"
							labels={[
								'All',
								...permissions.map((permission) => permission.role_name)
							]}
							values={[null, ...permissions.map((permission) => permission.id)]}
							bind:value={roleFilter}
							onInput={() => searchUsers(searchUserQuery)}
							disableFirstChoice
						/>

						<div class="rounded-md p-1">
							<Button
								Class="!p-1 border-none text-red-600 cursor-pointer hover:underline"
								buttonStyle="warning-light"
								onClick={resetFilter}>{$_('Reset Filter')}</Button
							>
						</div>
					</div>
				</div>
			</form>
		</div>

		<!-- Invites -->
		{#if usersAskingForInvite.length > 0}
			<div
				class="w-full flex-col gap-6 shadow rounded bg-white p-2 dark:bg-darkobject"
			>
				<span class="font-semibold text-sm text-gray-700 dark:text-darkmodeText"
					>{$_('Users requesting invite')}</span
				>
				{#each usersAskingForInvite as user}
					{#if user.external === true}
						<div
							class="text-black pt-4 flex align-middle outline-gray-200 w-full dark:text-darkmodeText dark:bg-darkobject"
						>
							<ProfilePicture
								Class="w-full"
								displayName
								username={user.username}
								profilePicture={user.profile_image}
							/>
							<Button
								Class="mr-4 px-2"
								buttonStyle="primary-light"
								onClick={() => acceptInviteUser(user.user)}
								>{$_('Accept')}</Button
							>
							<Button
								Class="px-2"
								buttonStyle="warning-light"
								onClick={() => denyInviteUser(user.user)}
								>{$_('Decline')}</Button
							>
						</div>
					{/if}
				{/each}
			</div>
		{/if}

		{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
			<UserSearch>
				<button
					slot="action"
					let:item
					class="ml-2 cursor-pointer"
					on:click={() => inviteUser(item.id)}
				>
					<Fa size="2x" icon={faEnvelope} />
				</button>
			</UserSearch>
		{/if}

		<!-- Members List -->
		{#if searchedUsers.length > 0}
			<div
				class="w-full p-4 flex flex-col gap-6 bg-white rounded shadow dark:bg-darkobject"
			>
				<span class="font-semibold text-sm text-gray-700 dark:text-darkmodeText"
					>{$_('All members')}</span
				>
				{#each searchedUsers as user}
					{#if ((user.is_admin && adminFilter === 'Admin') || (!user.is_admin && adminFilter === 'Member') || adminFilter === 'All') && (user.permission_id === roleFilter || roleFilter === null)}
						<div class="flex items-center">
							<button
								on:click={() =>
									goto(
										`/user?id=${user.user.id}&delegate_id=${user.delegate_pool_id || ''}&group_id=${
											$page.params.groupId
										}&is_admin=${adminFilter}`
									)}
								Class="w-[30%]"
							>
								<ProfilePicture
									Class=""
									username={user.user.username}
									profilePicture={user.user.profile_image}
									displayName
								/>
							</button>

							{#if user.delegate_pool_id !== null}
								<div
									class="bg-gray-300 px-2 py-0.5 rounded-lg dark:bg-gray-700 mr-2"
								>
									{$_('Delegate')}
								</div>
							{/if}
							{#if user?.is_admin}
								<div
									class="bg-gray-300 px-2 py-0.5 rounded-lg dark:bg-gray-700 mr-2"
								>
									{$_('Admin')}
								</div>
							{/if}
							<div class="bg-gray-300 px-2 py-0.5 rounded-lg dark:bg-gray-700">
								{user.permission_name}
							</div>
							<div class="flex gap-2 right-6 absolute">
								{#await getUserChannelId(user.user.id) then channelId}
									{#if channelId}
										<button
											on:click={() => {
												chatOpenStore.set(true);
												chatPartnerStore.set(channelId);
											}}
											Class="text-primary"
										>
											<Fa icon={faPaperPlane} rotate="60" />
										</button>
									{/if}
								{/await}
								{#if $groupUserStore?.is_admin && user.user.id !== ($userStore?.id || -1)}
									<Button
										Class="w-10 h-10 flex items-center justify-center pl-6 bg-transparent"
										onClick={() => (removeUserModalShow = true)}
									>
										<Fa size="lg" class="text-red-500" icon={faRunning} />
									</Button>
									<Modal
										bind:open={removeUserModalShow}
										Class="w-80 max-w-[400px]"
										buttons={[
											{
												label: 'Yes',
												type: 'warning',
												onClick: () => userRemove(user.user.id)
											},
											{
												label: 'No',
												type: 'default',
												onClick: () => (removeUserModalShow = false)
											}
										]}
									>
										<div slot="header">
											{$_('Kick ') + user.user.username + '?'}
										</div>
									</Modal>
								{/if}
							</div>
						</div>
					{/if}
				{/each}
			</div>
		{/if}
	</div>
</Loader>

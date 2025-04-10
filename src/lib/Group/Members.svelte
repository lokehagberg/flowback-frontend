<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Loader from '$lib/Generic/Loader.svelte';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import type { GroupUser, SelectablePages, User } from './interface';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faEnvelope } from '@fortawesome/free-solid-svg-icons/faEnvelope';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { groupMembers as groupMembersLimit } from '../Generic/APILimits.json';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import { env } from '$env/dynamic/public';
	import type { poppup } from '$lib/Generic/Poppup';
	import {
		faMagnifyingGlass,
		faPaperPlane,
		faRunning,
		faUserPlus
	} from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import Button from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { chatPartner, isChatOpen } from '$lib/Chat/ChatStore.svelte';
	import type { Delegate } from './Delegation/interfaces';
	import Select from '$lib/Generic/Select.svelte';
	import { getUserIsGroupAdmin } from '$lib/Generic/GenericFunctions';
	import { getUserChannelId } from '$lib/Chat/functions';

	let users: GroupUser[] = [],
		usersAskingForInvite: any[] = [],
		loading = true,
		selectedPage: SelectablePages = 'Members',
		searchUserQuery = '',
		searchInvitationQuery = '',
		searchedInvitationUsers: User[] = [],
		searchedUsers: GroupUser[] = [],
		poppup: poppup,
		showInvite = false,
		searched = false,
		delegates: Delegate[] = [],
		removeUserModalShow = false,
		userIsAdmin = false;

	let sortOrder: 'a-z' | 'z-a' | null = null;

	onMount(async () => {
		getUsers();
		getInvitesList();
		searchUsers('');
		getDelegatePools();
		userIsAdmin = await getUserIsGroupAdmin($page.params.groupId);

		//Does this one even do anything?
		fetchRequest('GET', `group/${$page.params.groupId}/invites`);
	});

	const getUsers = async () => {
		const token = localStorage.getItem('token') || '';
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?limit=${groupMembersLimit}`
		);
		users = json.results;
		loading = false;
	};

	const searchUser = async (username: string) => {
		//TODO: Search users
		//This code can be used to not show every user unless the user has typed in something
		if (username === '') {
			searchedInvitationUsers = [];
			return;
		}

		const { json } = await fetchRequest('GET', `users?username=${username}`);
		searchedInvitationUsers = json.results;
	};

	const searchUsers = async (username: string) => {
		//TODO: Search users
		//This code can be used to not show every user unless the user has typed in something
		// if (username === '') {
		// 	searchedInvitationUsers = [];
		// 	return;
		// }

		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?limit=${groupMembersLimit}&username__icontains=${username}`
		);

		searchedInvitationUsers = json.results;
		searchedUsers = json.results;
	};

	const getInvitesList = async () => {
		const { res, json } = await fetchRequest('GET', `group/${$page.params.groupId}/invites`);
		if (res.ok) usersAskingForInvite = json.results;
		// else poppup = { message: "Couldn't get invites list", success: false };
	};

	const inviteUser = async (userId: number) => {
		loading = true;
		const { res, json } = await fetchRequest('POST', `group/${$page.params.groupId}/invite`, {
			to: userId
		});

		loading = false;
		if (!res.ok) {
			poppup = { message: "Couldn't get invites list", success: false };
			return;
		}

		poppup = {
			success: true,
			message: 'Successfully sent invite'
		};

		searchInvitationQuery = '';
		searchedInvitationUsers = [];
	};

	const acceptInviteUser = async (userId: number) => {
		const {res, json } = await fetchRequest('POST', `group/${$page.params.groupId}/invite/accept`, {
			to: userId
		});

		usersAskingForInvite = usersAskingForInvite.filter((user) => user.id !== userId);

		if (!res.ok) {
			poppup = { message: "Couldn't accept user invite", success: false };
		}
		
		await getInvitesList();
		await getUsers();
		await searchUsers(searchUserQuery);
	};

	const denyInviteUser = async (userId: number) => {
		const { json } = await fetchRequest('POST', `group/${$page.params.groupId}/invite/reject`, {
			to: userId
		});
		usersAskingForInvite = usersAskingForInvite.filter((user) => user.id !== userId);
		await getInvitesList();
	};

	/*
		Temporary fix to make each delegate pool be associated with one user.
		TODO: Implement delegate pool feature in the front end (Figma design first)
	*/
	const getDelegatePools = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegate/pools?limit=1000`
		);

		if (!res.ok) return;

		delegates = json.results.map((delegatePool: any) => {
			return { ...delegatePool.delegates[0].group_user, pool_id: delegatePool.id };
		});
	};

	const userRemove = async (userToRemove: number) => {
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/user/delete`, {
			target_user_id: userToRemove
		});

		if (!res.ok) {
			poppup = { message: $_('Failed to remove user'), success: false };
			return;
		}

		poppup = { message: $_('Successfully removed user'), success: true };
		searchedUsers = searchedUsers.filter((user) => user.user.id !== userToRemove);
		removeUserModalShow = false;
		await getUsers();
	};

	const resetFilter = () => {};
</script>

<Modal bind:open={showInvite}>
	<div slot="body">
		<!-- Inviting -->
		<div class="w-full bg-white dark:bg-darkobject">
			<TextInput
				onInput={() => searchUser(searchInvitationQuery)}
				bind:value={searchInvitationQuery}
				label={$_('User to invite')}
				placeholder="Username"
			/>
			<ul>
				{#each searchedInvitationUsers as searchedUser}
					<li
						class="text-black flex justify-between bg-white p-2 w-full mt-6 dark:bg-darkobject dark:text-darkmodeText"
					>
						<div class="flex">
							<ProfilePicture
								displayName
								username={searchedUser.username}
								profilePicture={searchedUser.profile_image}
							/>
						</div>

						<div class="flex">
							<div
								class="ml-2 cursor-pointer"
								on:click={() => inviteUser(searchedUser.id)}
								on:keydown
								tabindex="0"
								role="button"
							>
								<Fa size="2x" icon={faEnvelope} />
							</div>
						</div>
					</li>
				{/each}
			</ul>
		</div>
	</div>
</Modal>

<Loader bind:loading>
	<div
		class="flex flex-col items-center gap-2 mb-24 relative dark:bg-darkobject dark:text-darkmodeText pb-2"
	>
		<!-- Search in Members list -->
		<div class="flex items-center gap-3 mb-4 w-full">
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

					<!-- TODO: Fix functionality for sorting -->
					<div class="flex flex-row items-center gap-1 pt-2">
						<span>{$_('Sort')}: </span>
						<Select
							classInner="p-1 font-semibold"
							labels={[$_('A - Z'), $_('Z - A')]}
							values={['a-z', 'z-a']}
							value={sortOrder || ''}
							onInput={() => searchUsers(searchUserQuery)}
							innerLabel="All"
							innerLabelOn={true}
						/>

						<!-- TODO: Fix functionality for filtering -->
						<span class="pl-4">{$_('Role')}: </span>
						<Select
							classInner="p-1 font-semibold"
							labels={[$_('Admin'), $_('Member')]}
							values={[$_('Admin'), $_('Member')]}
							value={''}
							onInput={() => searchUsers(searchUserQuery)}
							innerLabel="All"
							innerLabelOn={true}
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

			{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
				<Button
					Class="w-10 h-10 flex items-center justify-center"
					onClick={() => (showInvite = true)}
				>
					<Fa size="lg" icon={faUserPlus} />
				</Button>
			{/if}
		</div>

		<!-- Invites -->
		{#if usersAskingForInvite.length > 0}
			<div class="w-full p-4 flex-col gap-6 shadow rounded bg-white p-2 mb-4 dark:bg-darkobject">
				<span class="font-semibold text-sm text-gray-700">{$_('Users requesting invite')}</span>
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
								onClick={() => acceptInviteUser(user.user)}>{$_('Accept')}</Button
							>
							<Button
								Class="px-2"
								buttonStyle="warning-light"
								onClick={() => denyInviteUser(user.user)}>{$_('Decline')}</Button
							>
						</div>
					{/if}
				{/each}
			</div>
		{/if}

		<!-- Members List -->
		{#if searchedUsers.length > 0}
			<div class="w-full p-4 flex flex-col gap-6 bg-white rounded shadow dark:bg-darkobject">
				<span class="font-semibold text-sm text-gray-700">{$_('All members')}</span>
				{#each searchedUsers as user}
					{@const delegationId = delegates.find(
						(delegate) => delegate.user.id === user.user.id
					)?.pool_id}
					<div class="flex items-center">
						<button
							on:click={() => goto(`/user?id=${user.user.id}&delegate_id=${delegationId || ''}`)}
							Class="w-[30%]"
						>
							<ProfilePicture
								Class=""
								username={user.user.username}
								profilePicture={user.user.profile_image}
								displayName
							/>
						</button>

						{#if user.delegate_pool_id === null}
							<div class="bg-gray-300 px-2 py-0.5 rounded-lg dark:bg-gray-700 mr-2">
								{$_('Delegate')}
							</div>
						{/if}
						{#if user.is_admin}
							<div class="bg-gray-300 px-2 py-0.5 rounded-lg dark:bg-gray-700 mr-2">
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
											isChatOpen.set(true);
											chatPartner.set(channelId);
										}}
										Class="text-primary"
									>
										<Fa icon={faPaperPlane} rotate="60" />
									</button>
								{/if}
							{/await}
							{#if userIsAdmin && user.user.id !== (Number(localStorage.getItem('userId')) || 0)}
								<Button
									Class="w-10 h-10 flex items-center justify-center pl-6 bg-transparent"
									onClick={() => (removeUserModalShow = true)}
								>
									<Fa size="lg" class="text-red-500" icon={faRunning} />
								</Button>
								<Modal bind:open={removeUserModalShow} Class="w-80">
									<div slot="header">{$_('Kick ') + user.user.username + "?"}</div>
									<div slot="body" class="flex gap-4">
										<Button buttonStyle="warning-light" Class="w-[50%]" onClick={() => userRemove(user.user.id)}
											>{$_('Yes')}</Button
										>
										<Button buttonStyle="primary" Class="w-[50%]" onClick={() => (removeUserModalShow = false)}
											>{$_('No')}</Button
										>
									</div>
								</Modal>
							{/if}
						</div>
					</div>
				{/each}
			</div>
		{/if}
	</div>
</Loader>

<Poppup bind:poppup />

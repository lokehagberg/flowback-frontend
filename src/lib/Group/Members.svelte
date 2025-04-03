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
	import { faMagnifyingGlass, faPaperPlane, faRunning, faUserPlus } from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import Button from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { chatPartner, isChatOpen } from '$lib/Chat/ChatStore.svelte';
	import type { Delegate } from './Delegation/interfaces';

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
		removeUserModalShow = false;

	onMount(async () => {
		getUsers();

		getInvitesList();
		searchUsers('');
		getDelegatePools();

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
	};

	const acceptInviteUser = async (userId: number) => {
		const { json } = await fetchRequest('POST', `group/${$page.params.groupId}/invite/accept`, {
			to: userId
		});

		usersAskingForInvite = usersAskingForInvite.filter((user) => user.id !== userId);
	};

	const denyInviteUser = async (userId: number) => {
		const { json } = await fetchRequest('POST', `group/${$page.params.groupId}/invite/reject`, {
			to: userId
		});
		usersAskingForInvite = usersAskingForInvite.filter((user) => user.id !== userId);
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

	const userRemove = async () => {
		// const {res, json} = await fetchRequest('POST', {
		// } )
	};
</script>

<Modal bind:open={showInvite}>
	<div slot="body">
		<!-- Inviting -->
		<div class="w-full p-4 bg-white dark:bg-darkobject rounded shadow">
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

		<!-- Invites -->

		{#if usersAskingForInvite.length > 0}
			<div class="w-full shadow rounded bg-white p-2">
				<span>{$_('Users requesting invite')}</span>
				{#each usersAskingForInvite as user}
					{#if user.external === true}
						<div
							class="text-black p-2 flex align-middle outline-gray-200 w-full dark:text-darkmodeText dark:bg-darkobject"
						>
							<ProfilePicture
								Class="w-full"
								displayName
								username={user.username}
								profilePicture={user.profile_image}
							/>
							<Button
								Class="py-1 mr-4 px-2"
								buttonStyle="primary-light"
								onClick={() => acceptInviteUser(user.user)}>{$_('ACCEPT')}</Button
							>
							<Button
								Class="py-2  px-2"
								buttonStyle="warning"
								onClick={() => denyInviteUser(user.user)}>{$_('DECLINE')}</Button
							>
						</div>
					{/if}
				{/each}
			</div>
		{/if}
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
				<TextInput
					Class="w-full"
					onInput={() => (searched = false)}
					label=''
					max={null}
					search={true}
					placeholder={$_('Search members')}
					bind:value={searchUserQuery}
				/>
			</form>

			{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
				<Button Class="w-10 h-10 flex items-center justify-center" onClick={() => (showInvite = true)}>
					<Fa size="lg" icon={faUserPlus} />
				</Button>
			{/if}
		</div>

		<!-- Members List -->
		{#if searchedUsers.length > 0}
			<div class="w-full p-4 flex flex-col gap-6 bg-white rounded shadow dark:bg-darkobject">
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
							<!-- <Button buttonStyle="warning-light" onClick={() => (removeUserModalShow = true)}
								><Fa icon={faRunning} /></Button
							> -->
							<button
								on:click={() => {
									console.log(user, "USSR");
									
									isChatOpen.set(true);
									chatPartner.set(user.user.id);
								}}
								Class="text-primary"
							>
								<Fa icon={faPaperPlane} rotate="60" />
							</button>
						</div>
					</div>
				{/each}
			</div>
		{/if}
	</div>
</Loader>

<Modal bind:open={removeUserModalShow}>
	<div slot="header">{$_('Sure you want to delete?')}</div>
	<div slot="body">
		<Button buttonStyle="warning-light" onClick={userRemove} />
	</div>
</Modal>

<Poppup bind:poppup />

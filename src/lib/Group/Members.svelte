<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Loader from '$lib/Generic/Loader.svelte';
	import Tab from '$lib/Generic/Tab.svelte';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import type { GroupUser, SelectablePages, User } from './interface';
	import { _ } from 'svelte-i18n';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faEnvelope } from '@fortawesome/free-solid-svg-icons/faEnvelope';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { groupMembers as groupMembersLimit } from '../Generic/APILimits.json';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import { env } from '$env/dynamic/public';
	import type { poppup } from '$lib/Generic/Poppup';
	import { faPaperPlane } from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import Button from '$lib/Generic/Button.svelte';

	let users: GroupUser[] = [],
		usersAskingForInvite: any[] = [],
		loading = true,
		selectedPage: SelectablePages = 'Members',
		searchUser = '',
		searchedUsers: User[] = [],
		poppup: poppup;

	onMount(async () => {
		getUsers();

		getInvitesList();

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

	const searchUsers = async (username: string) => {
		//TODO: Search users
		//This code can be used to not show every user unless the user has typed in something
		if (username === '') {
			searchedUsers = [];
			return;
		}

		const { json } = await fetchRequest(
			'GET',
			`users?limit=${groupMembersLimit}&username=${username}`
		);
		searchedUsers = json.results;
	};

	const getInvitesList = async () => {
		const { res, json } = await fetchRequest('GET', `group/${$page.params.groupId}/invites`);
		if (res.ok) usersAskingForInvite = json.results;
		else poppup = { message: "Couldn't get invites list", success: false };
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
</script>

<Loader bind:loading>
	<div
		class="flex flex-col items-center gap-2 mb-24 relative dark:bg-darkobject dark:text-darkmodeText pb-2"
	>
		<!-- Inviting -->

		<div class="w-full p-4 bg-white rounded shadow">
			<TextInput
				onInput={() => searchUsers(searchUser)}
				bind:value={searchUser}
				label="User to invite"
				placeholder="Username"
			/>
			<ul>
				{#each searchedUsers as searchedUser}
					<li
						class="text-black flex justify-between bg-white p-2 w-full mt-6 dark:bg-darkobject dark:text-darkmodeText"
					>
						<div class="flex">
							<ProfilePicture
								username={searchedUser.username}
								profilePicture={searchedUser.profile_image}
							/>
							<div class="w-64 ml-10">{searchedUser.username}</div>
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
				<span>Users requesting invite</span>
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
								action={() => acceptInviteUser(user.user)}>{$_('ACCEPT')}</Button
							>
							<Button
								Class="py-2  px-2"
								buttonStyle="warning"
								action={() => denyInviteUser(user.user)}>{$_('DECLINE')}</Button
							>
						</div>
					{/if}
				{/each}
			</div>
		{/if}

		<!-- Members List -->

		{#if users.length > 0}
			<div class="w-full p-4 flex flex-col gap-6 bg-white rounded shadow">
				{#each users as user}
					<div class="flex items-center">
						<ProfilePicture
							Class="w-[30%]"
							username={user.user.username}
							profilePicture={user.user.profile_image}
							displayName
						/>
						<div class="bg-gray-300 px-2 py-0.5 rounded-lg">
							{user.permission_name}
						</div>
						<div
							on:click={() => goto(`/user?id=${user.user.id}`)}
							on:keydown
							tabindex="0"
							role="button"
							Class="right-6 absolute"
						>
							<Fa icon={faPaperPlane} rotate="60" />
						</div>
					</div>
				{/each}
			</div>
		{/if}
	</div>
</Loader>

<Poppup bind:poppup />

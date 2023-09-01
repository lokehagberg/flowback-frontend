<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Loader from '$lib/Generic/Loader.svelte';
	import Tab from '$lib/Generic/Tab.svelte';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import type { GroupUser, SelectablePages, User } from './interface';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faCheck } from '@fortawesome/free-solid-svg-icons/faCheck';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faEnvelope } from '@fortawesome/free-solid-svg-icons/faEnvelope';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { groupMembers as groupMembersLimit } from '../Generic/APILimits.json'

	let users: GroupUser[] = [];
	let loading = true;
	let selectedPage: SelectablePages = 'Members';
	let searchUser = '';
	let searchedUsers: User[] = [];

	onMount(async () => {
		const token = localStorage.getItem('token') || '';
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/users?limit=${groupMembersLimit}`);
		users = json.results;
		loading = false;

		getInvitesList();

		fetchRequest('GET', `group/${$page.params.groupId}/invites`)
	});

	const searchUsers = async (username: string) => {
		//TODO: Search users
		//This code can be used to not show every user unless the user has typed in something
		if (username === '') {
			searchedUsers = [];
			return;
		}

		const { json } = await fetchRequest('GET', `users?limit=${groupMembersLimit}&username=${username}`);
		searchedUsers = json.results;
	};

	const getInvitesList = async () => {
		const { json } = await fetchRequest('GET', `group/invites?group=${$page.params.groupId}`);
	};

	const inviteUser = async (userId: number) => {
		const { json } = await fetchRequest('POST', `group/${$page.params.groupId}/invite`, {
			to: userId
		});
	};

	const acceptInviteUser = async (userId: number) => {
		const { json } = await fetchRequest('POST', `group/${$page.params.groupId}/invite/accept`, {
			to: userId
		});
	};

	const denyInviteUser = async (userId: number) => {
		const { json } = await fetchRequest('POST', `group/${$page.params.groupId}/invite/reject`, {
			to: userId
		});
	};

	$: if (selectedPage === 'Invite') searchUsers('');
</script>

<Loader bind:loading>
	<div class="flex flex-col items-center gap-2 mb-24 bg-white shadow rounded relative dark:bg-darkobject dark:text-darkmodeText">
		<Tab
			bind:selectedPage
			tabs={import.meta.env.VITE_MODE === 'DEV' ? ['Members', 'Invite'] : ['Members', 'Invite']}
		/>
		{#if selectedPage === 'Members' && users.length > 0}
			<div class="w-full p-6 flex flex-col gap-6">
				{#each users as user}
					<a
						class="text-black flex bg-white p-2 hover:outline outline-gray-200 cursor-pointer w-full dark:text-darkmodeText dark:bg-darkobject"
						href={`/user?id=${user.user.id}`}
					>
						<ProfilePicture user={user}/>
						<div class="w-64 ml-10 hover:underline">{user.user.username}</div>
					</a>
				{/each}
			</div>
		{:else if selectedPage === 'Pending Invites' && users.length > 0}
			{#each users as user}
				<a
					class="text-black flex bg-white p-2 hover:outline outline-gray-200 cursor-pointer w-full"
					href={`/user?id=${user.id}`}
				>
					<ProfilePicture user={user}/>
					<div class="w-64 ml-10 hover">{user.user.username}</div>
					<div class="w-64 ml-10 hover:underline">{$_('ACCEPT')}</div>
				</a>
			{/each}
		{:else if selectedPage === 'Invite'}
			<div class="w-full p-6">
				<TextInput
					onInput={() => searchUsers(searchUser)}
					bind:value={searchUser}
					label="User to invite"
				/>
				<ul>
					{#each searchedUsers as searchedUser}
						<li class="text-black flex justify-between bg-white p-2 w-full mt-6">
							<div class="flex">
								<ProfilePicture user={searchedUser}/>
								<div class="w-64 ml-10">{searchedUser.username}</div>
							</div>

							<div class="flex">
								<div class="cursor-pointer" on:click={() => acceptInviteUser(searchedUser.id)}>
									<Fa size="2x" color="blue" icon={faCheck} />
								</div>
								<div class="ml-2 cursor-pointer" on:click={() => denyInviteUser(searchedUser.id)}>
									<Fa size="2x" color="#CC4444" icon={faX} />
								</div>
								<div class="ml-2 cursor-pointer" on:click={() => inviteUser(searchedUser.id)}>
									<Fa size="2x" icon={faEnvelope} />
								</div>
							</div>
						</li>
					{/each}
				</ul>
			</div>
		{/if}
	</div>
</Loader>

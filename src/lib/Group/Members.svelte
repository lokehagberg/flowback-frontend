<script lang="ts">
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import Loader from '$lib/Generic/Loader.svelte';
	import Tab from '$lib/Generic/Tab.svelte';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import type { SelectablePages, User } from './interface';
	import DefaultPFP from '$lib/assets/Default_pfp.png';

	let users: User[] = [];
	let loading = true;
	let selectedPage: SelectablePages = 'Members';
	let searchUser = '';
	let searchedUsers: User[] = [];

	onMount(async () => {
		const token = localStorage.getItem('token') || '';
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/users?limit=100`);
		users = json.results;
		loading = false;
	});

	const searchUsers = async (username: string) => {
		//This code can be used to not show every user unless the user has typed in something
		// if (username === '') {
		// 	searchedUsers = [];
		// 	return;
		// }

		const { json } = await fetchRequest('GET', `users?limit=100&username=${username}`);
		searchedUsers = json.results;
	};

	$: if (selectedPage === 'Invite') searchUsers('');
</script>

<Loader bind:loading />
<div class="flex flex-col items-center gap-2 mb-24 bg-white shadow rounded">
	<Tab bind:selectedPage tabs={['Members', 'Invite']} />
	{#if selectedPage === 'Members' && users.length > 0}
		<div class="w-full p-6 flex flex-col gap-6">
			{#each users as user}
				<a
					class="text-black flex bg-white p-2 hover:outline outline-gray-200 cursor-pointer w-full"
					href={`/user?id=${user.user_id}`}
				>
					<img src={DefaultPFP} alt="avatar" class="w-10 h-10" />
					<div class="w-64 ml-10 hover:underline">{user.username}</div>
				</a>
			{/each}
		</div>
	{:else if selectedPage === 'Pending Invites' && users.length > 0}
		{#each users as user}
			<a
				class="text-black flex bg-white p-2 hover:outline outline-gray-200 cursor-pointer w-full"
				href={`/user?id=${user.id}`}
			>
				<img src={DefaultPFP} alt="avatar" class="w-10 h-10" />
				<div class="w-64 ml-10 hover">{user.username}</div>
				<div class="w-64 ml-10 hover:underline">ACCEPT</div>
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
					<li class="text-black flex bg-white p-2 w-full mt-6">
						<img src={DefaultPFP} alt="avatar" class="w-10 h-10" />
						<div class="w-64 ml-10">{searchedUser.username}</div>
						<ButtonPrimary Class={'w-64 ml-10 hover:underline cursor-pointer hover:bg-blue-800'}
							>INVITE</ButtonPrimary
						>
					</li>
				{/each}
			</ul>
		</div>
	{/if}
</div>

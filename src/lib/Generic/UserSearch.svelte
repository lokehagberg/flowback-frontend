<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import { userStore, type User } from '$lib/User/interfaces';
	import Modal from './Modal.svelte';
	import ProfilePicture from './ProfilePicture.svelte';
	import TextInput from './TextInput.svelte';

	export let showUsers = false,
		showSelf = false;

	let searchedUsers: User[] = [],
		search = '';

	const searchUser = async (username: string) => {
		if (username === '') {
			searchedUsers = [];
			return;
		}

		const { json } = await fetchRequest('GET', `users?username=${username}`);
		searchedUsers = json?.results;
	};
</script>

<div
	class="p-4 shadow w-full bg-white dark:bg-darkobject flex items-center hover:bg-gray-100 dark:hover:bg-darkmodeObject transition-colors"
>
	<button on:click={() => (showUsers = true)} class="flex items-center gap-4 w-full" type="button">
		<ProfilePicture />
		<div class="bg-gray-300 px-2 py-0.5 rounded-lg dark:bg-gray-700">+ Invite user</div>
	</button>
</div>

<!-- TODO: Don't force UserSearch prop to be a Modal. Make it optional -->
<Modal bind:open={showUsers} Class="bg-white dark:bg-darkobject !cursor-default">
	<div slot="body">
		<TextInput
			onInput={() => searchUser(search)}
			bind:value={search}
			label={$_('User to invite')}
			placeholder="Username"
		/>
		<ul>
			{#each searchedUsers as user}
				{#if !(showSelf === false && $userStore?.id === user.id)}
					<li class="flex justify-between mt-6">
						<ProfilePicture
							displayName
							username={user.username}
							profilePicture={user.profile_image}
						/>

						<slot name="action" item={user} />
					</li>
				{/if}
			{/each}
		</ul>
	</div>
</Modal>

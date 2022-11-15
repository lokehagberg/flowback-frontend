<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { User } from '$lib/User/interfaces';
	import Layout from '$lib/Generic/Layout.svelte';
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import { _ } from 'svelte-i18n';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';

	let user: User = {
		banner_image: '',
		bio: '',
		email: '',
		profile_image: '',
		username: '',
		website: '',
		id: 0
	};

	let userEdit: User = {
		banner_image: '',
		bio: '',
		email: '',
		profile_image: '',
		username: '',
		website: '',
		id: 0
	};

	let isUser = false,
		isEditing = true,
		profile_image = DefaultPFP,
		currentlyEditing: null | 'bio' = null,
		status: StatusMessageInfo;

	onMount(async () => {
		//The URL has no ID if the user is on their own profile
		const userId = $page.url.searchParams.get('id');
		isUser = userId ? false : true;

		const { res, json } = await fetchRequest('GET', isUser ? 'user' : `users?id=${userId}`);
		user = isUser ? json : json.results[0];
		userEdit = user;
	});

	const updateProfile = async () => {
		const { res, json } = await fetchRequest('POST', `user/update`, { bio: userEdit.bio });
		if (res.ok) user = userEdit;
		status = statusMessageFormatter(res, json);
	};

	console.log($page.url.searchParams.get('id'));
</script>

<Layout centering={true}>
	{#if !isEditing}
		<div class="bg-red-500 h-48 w-full" />
		<div class="w-full md:w-2/3 bg-white shadow rounded p-8">
			<img src={profile_image} class="h-36 w-36 inline" alt="avatar" />
			<h1 class="inline ml-8">{user.username}</h1>
			<!-- {#if user.website} -->
			<!-- <h2 class="inline">Website: {user.website}</h2> -->
			<!-- {/if} -->
			<p class="mt-8">
				{$_(user.website || '')}
			</p>
			<p class="mt-8">
				{$_(user.bio || 'This user has no bio')}
			</p>
			<StatusMessage bind:status />
			<div class="mt-6">
				<ButtonPrimary action={() => (isEditing = true)}>Redigera Profil</ButtonPrimary>
			</div>
		</div>
	{:else}
		<div class="bg-red-500 h-48 w-full" />
		<div class="w-full md:w-2/3 bg-white shadow rounded p-8 mb-8">
			<img src={profile_image} class="h-36 w-36 inline hover:bg-gray-300" alt="avatar" />
			<h1 class=" hover:bg-gray-300">{user.username}</h1>
			<!-- {#if user.website} -->
			<!-- <h2 class="inline">Website: {user.website}</h2> -->
			<!-- {/if} -->
			<p class="pt-4 pb-4 hover:bg-gray-300">
				{$_(user.website || 'Add Website')}
			</p>

			{#if currentlyEditing === 'bio'}
				<TextArea
					autofocus
					onBlur={() => (currentlyEditing = null)}
					label={'Bio'}
					bind:value={userEdit.bio}
					Class="pt-8 pb-8 "
				/>
			{:else}
				<p
					on:click={() => (currentlyEditing = 'bio')}
					class="pt-8 pb-8 pl-4 pr-4 text-center transition transition-color cursor-pointer hover:bg-gray-300 rounded-xl"
				>
					{$_(userEdit.bio || 'Add Bio')}
				</p>
			{/if}
			<StatusMessage Class="mt-4" bind:status />
			<div class="mt-6">
				<ButtonPrimary
					Class="mt-4"
					action={() => {
						updateProfile();
						isEditing = false;
					}}>Spara Ändringar</ButtonPrimary
				>
				<ButtonPrimary Class="mt-4" action={() => (isEditing = false)}>Ångra</ButtonPrimary>
			</div>
		</div>
	{/if}
</Layout>

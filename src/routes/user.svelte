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
	import TextInput from '$lib/Generic/TextInput.svelte';

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
		profile_image_preview:File,
		currentlyEditing: null | 'bio' | 'web' | 'name' = null,
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
		const formData = new FormData();
		formData.append('username', userEdit.username);
		formData.append('bio', userEdit.bio);
		formData.append('website', userEdit.website);
		formData.append('profile_image', profile_image_preview);

		const { res, json } = await fetchRequest('POST', `user/update`, formData, true, false);
		if (res.ok) user = userEdit;
		status = statusMessageFormatter(res, json);
	};

	const handleProfileImageChange = (e: any) => {
		const files: File[] = Array.from(e.target.files);
		profile_image_preview = files[0];
	};
</script>

<Layout centering={true}>
	{#if !isEditing}
		<div class="bg-red-500 h-48 w-full" />
		<div class="w-full md:w-2/3 bg-white shadow rounded p-8 mb-8">
			<img src={user.profile_image} class="h-36 w-36 inline rounded-full" alt="avatar" />
			<h1 class="inline ml-8">{user.username}</h1>
			<a class="block mt-6" href={user.website}>
				{$_(user.website || '')}
			</a>
			<p class="mt-6 whitespace-pre-wrap">
				{$_(user.bio || 'This user has no bio')}
			</p>
			<StatusMessage Class="mt-6" bind:status />
			<div class="mt-8">
				<ButtonPrimary action={() => (isEditing = true)}>Redigera Profil</ButtonPrimary>
			</div>
		</div>
	{:else}
		<div class="bg-red-500 h-48 w-full" />
		<form
			class="w-full md:w-2/3 bg-white shadow rounded p-8 mb-8"
			on:submit|preventDefault={() => {}}
		>
			<img src={userEdit.profile_image.toString()} class="h-36 w-36 inline rounded-full" alt="avatar" />
			<input type="file" id="file-ip-1" accept="image/*" on:change={handleProfileImageChange} />

			{#if currentlyEditing === 'name'}
				<TextInput
					autofocus
					onBlur={() => (currentlyEditing = null)}
					label={'Name'}
					bind:value={userEdit.username}
					Class="pt-8 pb-8 "
				/>
			{:else}
				<h1
					on:click={() => (currentlyEditing = 'name')}
					class="pt-4 pb-4 pl-4 pr-4 text-center transition transition-color cursor-pointer hover:bg-gray-300 rounded-xl"
				>
					{$_(userEdit.username || 'Add Username')}
				</h1>
			{/if}
			{#if currentlyEditing === 'web'}
				<TextInput
					autofocus
					onBlur={() => (currentlyEditing = null)}
					label={'Website'}
					bind:value={userEdit.website}
					Class="pt-8 pb-8 "
				/>
			{:else}
				<p
					on:click={() => (currentlyEditing = 'web')}
					class="pt-4 pb-4 pl-4 pr-4 text-center transition transition-color cursor-pointer hover:bg-gray-300 rounded-xl"
				>
					{$_(userEdit.website || 'Add Website')}
				</p>
			{/if}
			{#if currentlyEditing === 'bio'}
				<TextArea
					autofocus
					onBlur={() => (currentlyEditing = null)}
					label={'Bio'}
					bind:value={userEdit.bio}
					Class="pt-8 pb-8 whitespace-pre-wrap"
				/>
			{:else}
				<p
					on:click={() => (currentlyEditing = 'bio')}
					class="pt-8 pb-8 pl-4 pr-4 transition transition-color cursor-pointer hover:bg-gray-300 rounded-xl whitespace-pre-wrap"
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
		</form>
	{/if}
</Layout>

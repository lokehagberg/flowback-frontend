<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { User } from '$lib/User/interfaces';
	import Layout from '$lib/Generic/Layout.svelte';
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import DefaultBanner from '$lib/assets/default_banner_user.png';
	import { _ } from 'svelte-i18n';
	import Button from '$lib/Generic/Button.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import getCroppedImg from '$lib/Generic/Cropper/canvasUtils';
	import CropperModal from '$lib/Generic/Cropper/CropperModal.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';

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
		isEditing = false,
		profileImagePreview = DefaultPFP,
		bannerImagePreview = '',
		currentlyEditing: null | 'bio' | 'web' | 'name' = null,
		status: StatusMessageInfo | undefined,
		currentlyCroppingProfile: boolean = false,
		currentlyCroppingBanner = false,
		oldProfileImagePreview = '',
		oldBannerImagePreview = '',
		file: Blob,
		croppedImage: any;

	onMount(() => {
		getUser();
	});

	const getUser = async () => {
		//The URL has no ID if the user is on their own profile
		const userId = $page.url.searchParams.get('id');
		isUser = userId ? false : true;

		const { res, json } = await fetchRequest('GET', isUser ? 'user' : `users?id=${userId}`);
		user = isUser ? json : json.results[0];
		userEdit = user;
		if (user.profile_image)
			profileImagePreview = `${import.meta.env.VITE_API}${
				!(import.meta.env.VITE_IMAGE_HAS_API === 'TRUE') ? '' : '/api'
			}${user.profile_image}`;
		if (user.banner_image) bannerImagePreview = `${import.meta.env.VITE_API}${user.banner_image}`;

		document.title = `${user.username}'s profile`;
	};

	const blobifyImages = async (profileImagePreview: any) => {
		const image = await fetch(profileImagePreview)
			.then((res) => res.blob())
			.then((blob) => {
				const file = new File([blob], 'dot.png', blob);
				return file;
			});

		return image;
	};

	const updateProfile = async () => {
		const imageToSend = await blobifyImages(profileImagePreview);
		const bannerImageToSend = await blobifyImages(bannerImagePreview);

		const formData = new FormData();
		formData.append('username', userEdit.username);
		formData.append('bio', userEdit.bio || '');
		formData.append('website', userEdit.website || '');
		if (bannerImageToSend) formData.append('banner_image', bannerImageToSend);
		if (imageToSend) formData.append('profile_image', imageToSend);

		const { res, json } = await fetchRequest('POST', `user/update`, formData, true, false);
		if (res.ok) {
			user = userEdit;
			isEditing = false;
		}
		status = statusMessageFormatter(res, json);
	};

	const handleCropProfileImage = async (e: any) => {
		//Type string, for preview image
		oldProfileImagePreview = profileImagePreview;
		if (e.target.files.length > 0) profileImagePreview = URL.createObjectURL(e.target.files[0]);
		currentlyCroppingProfile = true;
	};

	const handleCropBanner = async (e: any) => {
		//Type string, for preview image
		oldBannerImagePreview = profileImagePreview;
		if (e.target.files.length > 0) bannerImagePreview = URL.createObjectURL(e.target.files[0]);
		currentlyCroppingBanner = true;
	};
</script>

{#if currentlyCroppingProfile || currentlyCroppingBanner}
	<!-- Cropp image -->
	<CropperModal
		confirmAction={(image) => {
			file = image;
			if (currentlyCroppingProfile) profileImagePreview = croppedImage;
			else if (currentlyCroppingBanner) bannerImagePreview = croppedImage;

			currentlyCroppingProfile = false;
			currentlyCroppingBanner = false;
		}}
		cancelAction={() => {
			currentlyCroppingProfile = false;
			currentlyCroppingBanner = false;
		}}
		bind:croppedImage
		image={profileImagePreview}
		bind:userEdit
		bind:currentlyCroppingProfile
	/>
{/if}

<!-- Viewing someone's profile -->
<Layout centered>
	{#if !isEditing}
		<img
			src={bannerImagePreview || DefaultBanner}
			class="bg-gray-200 w-full cover max-h-[30vh] xl:max-h-[25vh]"
			alt="banner"
		/>
		<div
			class="w-full md:w-2/3 bg-white shadow rounded p-8 mb-8 dark:bg-darkobject dark:text-darkmodeText"
		>
			<img
				src={profileImagePreview}
				class="h-36 w-36 inline rounded-full profile"
				alt="avatar"
				id="avatar"
			/>
			<h1 class="inline ml-8">{user.username}</h1>
			<a class={`block mt-6`} href={user.website || ''}>
				{user.website || ''}
			</a>
			<p class="mt-6 whitespace-pre-wrap">
				{user.bio || $_('This user has no bio')}
			</p>
			<StatusMessage Class="mt-6" bind:status />
			{#if isUser}
				<div class="mt-8">
					<Button action={() => (isEditing = true)}>{$_('Edit profile')}</Button>
				</div>
			{/if}
		</div>

		<!-- Editing your own profile -->
	{:else}
		<!-- Banner Image -->
		<label for="file-ip-2" class="bg-gray-200 w-full h-[40%] cover">
			<img
				src={currentlyCroppingProfile ? oldBannerImagePreview : bannerImagePreview}
				class="w-full cover transition-all filter hover:grayscale-[70%] hover:brightness-[90%] backdrop-grayscale"
				alt="banner"
			/>
			<input
				class="hidden"
				type="file"
				id="file-ip-2"
				accept="image/*"
				on:change={handleCropBanner}
			/>
		</label>
		<form
			class="w-full md:w-2/3 bg-white shadow rounded p-8 mb-8 dark:bg-darkobject dark:text-darkmodeText"
			on:submit|preventDefault={() => {}}
		>
			<label for="file-ip-1" class="inline">
				<!-- Profile PIcture -->
				<img
					src={currentlyCroppingProfile ? oldProfileImagePreview : profileImagePreview}
					class="mt-6 h-36 w-36 inline rounded-full transition-all filter hover:grayscale-[70%] hover:brightness-[90%] backdrop-grayscale"
					alt="avatar"
					id="avatar"
				/>
				<input
					class="hidden"
					type="file"
					name="file-ip-1"
					id="file-ip-1"
					accept="image/*"
					on:change={handleCropProfileImage}
				/></label
			>

			{#if currentlyEditing === 'name'}
				<TextInput
					autofocus
					onBlur={() => (currentlyEditing = null)}
					label={'Name'}
					bind:value={userEdit.username}
					Class="mt-6 pt-8 pb-8 inline"
				/>
			{:else}
				<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
				<!-- svelte-ignore a11y-click-events-have-key-events -->
				<h1
					on:click={() => (currentlyEditing = 'name')}
					class="mt-6 pt-4 pb-4 pl-4 pr-4 text-center transition transition-color cursor-pointer hover:bg-gray-300 rounded-xl inline"
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
				<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
				<!-- svelte-ignore a11y-click-events-have-key-events -->
				<p
					on:click={() => (currentlyEditing = 'web')}
					class="pt-4 pb-4 pl-4 pr-4 text-center transition transition-color cursor-pointer hover:bg-gray-300 rounded-xl"
				>
					{userEdit.website || $_('Add Website')}
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
				<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
				<!-- svelte-ignore a11y-click-events-have-key-events -->
				<p
					on:click={() => (currentlyEditing = 'bio')}
					class="pt-8 pb-8 pl-4 pr-4 transition transition-color cursor-pointer hover:bg-gray-300 rounded-xl whitespace-pre-wrap"
				>
					{userEdit.bio || $_('Add Bio')}
				</p>
			{/if}
			<StatusMessage Class="mt-4" bind:status />
			<span>{$_('Recommended ratios for images: 1:1 for profile, 4:1 for banner')}</span>
			<div class="mt-6">
				<Button Class="mt-4" action={updateProfile}>{$_('Save changes')}</Button>
				<Button Class="mt-4" action={() => (isEditing = false)}>{$_('Cancel')}</Button>
			</div>
		</form>
	{/if}
</Layout>

<Poppup poppup={{ message: 'hi', success: true }} />

<style>
	img.cover {
		aspect-ratio: 4;
		/* width: 100%; */
	}

	img.profile {
		width: 100px;
		height: 100px;
	}
</style>

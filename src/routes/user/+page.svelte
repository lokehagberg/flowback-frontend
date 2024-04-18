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
		status: StatusMessageInfo | undefined;

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
			profileImagePreview = `${import.meta.env.VITE_API}${!(import.meta.env.VITE_IMAGE_HAS_API === "TRUE") ? '' : '/api'}${user.profile_image}`;
		if (user.banner_image) bannerImagePreview = `${import.meta.env.VITE_API}${user.banner_image}`;

		document.title = `${user.username}'s profile`;
	}

	const updateProfile = async () => {
		const formData = new FormData();
		formData.append('username', userEdit.username);
		formData.append('bio', userEdit.bio || '');
		formData.append('website', userEdit.website || '');
		if (userEdit.banner_image_file) formData.append('banner_image', userEdit.banner_image_file);
		if (files) formData.append('profile_image', files);
		// if (userEdit.profile_image_file) formData.append('profile_image', files[0]);

		const { res, json } = await fetchRequest('POST', `user/update`, formData, true, false);
		if (res.ok) {
			user = userEdit;
			isEditing = false;
		}
		status = statusMessageFormatter(res, json);
	};
	// TODO: Fix cropping
	let currentlyCroppingProfile: boolean = false,
		currentlyCroppingBanner = false,
		oldProfileImagePreview = '',
		files: File,
		crop: any,
		pixelCrop: any,
		croppedImage: any;


	// TODO: Fix cropping
	const handleCropProfileImage = (e: any) => {
		//Type string, for preview image
		oldProfileImagePreview = profileImagePreview;
		if (e.target.files.length > 0) profileImagePreview = URL.createObjectURL(e.target.files[0]);
		// files = Array.from(e.target.files);
		files = e.target.files[0]
		currentlyCroppingProfile = true;
		setTimeout(() => {
			grabBlob();
		}, 2000);
	};

	const handleProfileImageChange = async (e: any) => {
		//Max 2 MB filesize
		if (e.target.files[0].size > 2097152) {
			status = { success: false, message: 'No filesize greater than 2MB' };
			return;
		}
		status = undefined;
		//Type string, for preview image
		if (e.target.files.length > 0) profileImagePreview = URL.createObjectURL(e.target.files[0]);

		//Type File, for sending to server
		const files: File[] = Array.from(e.target.files);
		userEdit.profile_image_file = files[0];

		// @ts-ignore
		// userEdit.profile_image_file = await getCroppedImg(profileImagePreview, pixelCrop);
		// profileImagePreview = await getCroppedImg(profileImagePreview, crop.pixels)
		currentlyCroppingProfile = false;
		//Type File, for sending to server
		// userEdit.profile_image_file = files[0];
	};

	const handleBannerImageChange = (e: any) => {
		//Type string, for preview image
		if (e.target.files.length > 0) bannerImagePreview = URL.createObjectURL(e.target.files[0]);
		//Type File, for sending to server
		const files: File[] = Array.from(e.target.files);
		userEdit.banner_image_file = files[0];
	};

	const grabBlob = () => {
		const img:any = document.querySelector("#avatar")
		console.log(img?.src)
	}
</script>

{#if currentlyCroppingProfile}
	<!-- Cropp image -->
	<CropperModal
		confirmAction={() => {
			profileImagePreview = croppedImage;
			currentlyCroppingProfile = false
		}}
		cancelAction={() => (currentlyCroppingProfile = false)}
		bind:croppedImage
		image={profileImagePreview}
		bind:userEdit
	/>
	<!-- <div class="z-50 fixed p-4 bg-white left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2">
		<h1>Crop profile picture</h1>
		<div class=" bg-white relative w-[30vw] aspect-square mb-6">
			<Cropper
				bind:crop
				image={profileImagePreview}
				showGrid={false}
				cropShape={'round'}
				zoomSpeed={0.1}
				aspect={1}
				on:cropcomplete={(e) => pixelCrop = e.detail.pixels}
			/>
		</div>
		<Button buttonStyle="primary" action={handleProfileImageChange}>Confirm</Button>
		<Button
			buttonStyle="secondary"
			action={() => {
				currentlyCroppingProfile = false;
				profileImagePreview = oldProfileImagePreview;
				files = [];
				// userEdit.profile_image_file = new File([], '');
			}}>Cancel</Button
		>
	</div> -->
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
			<img src={profileImagePreview} class="h-36 w-36 inline rounded-full profile" alt="avatar" id="avatar"/>
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
				src={bannerImagePreview}
				class="w-full cover transition-all filter hover:grayscale-[70%] hover:brightness-[90%] backdrop-grayscale"
				alt="banner"
			/>
			<input
				class="hidden"
				type="file"
				id="file-ip-2"
				accept="image/*"
				on:change={handleBannerImageChange}
			/>
		</label>
		<form
			class="w-full md:w-2/3 bg-white shadow rounded p-8 mb-8 dark:bg-darkobject dark:text-darkmodeText"
			on:submit|preventDefault={() => {}}
		>
			<label for="file-ip-1" class="inline">
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

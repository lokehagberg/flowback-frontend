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
	import { blobifyImages, type StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import CropperModal from '$lib/Generic/Cropper/CropperModal.svelte';
	import { pfpStore } from '$lib/Login/stores';
	import { env } from '$env/dynamic/public';
	import Fa from 'svelte-fa';
	import { faArrowLeft, faPen } from '@fortawesome/free-solid-svg-icons';
	import History from '$lib/Group/Delegation/History.svelte';
	import { goto } from '$app/navigation';
	import { getStores } from '$app/stores';
	import { delegation as delegationLimit } from '$lib/Generic/APILimits.json';
	import { TelInput, normalizedCountries } from 'svelte-tel-input';
	import type { DetailedValue, CountryCode, E164Number } from 'svelte-tel-input/types';

	let user: User = {
		banner_image: '',
		bio: '',
		email: '',
		profile_image: '',
		username: '',
		website: '',
		contact_email: '',
		contact_phone: '',
		id: 0
	};

	let userEdit: User = {
		banner_image: '',
		bio: '',
		email: '',
		profile_image: '',
		username: '',
		website: '',
		contact_email: '',
		contact_phone: '',
		id: 0
	};

	let isUser = false,
		isEditing = false,
		profileImagePreview = DefaultPFP,
		bannerImagePreview = '',
		currentlyEditing: null | 'bio' | 'web' | 'name' | 'phone' | 'email' = null,
		status: StatusMessageInfo | undefined,
		currentlyCroppingProfile: boolean = false,
		currentlyCroppingBanner = false,
		oldProfileImagePreview = '',
		oldBannerImagePreview = '',
		croppedImage: string;

	const { navigating: nav } = getStores();

	// Any Country Code Alpha-2 (ISO 3166)
	let selectedCountry: CountryCode | null = 'SE';

	// You must use E164 number format. It's guarantee the parsing and storing consistency.
	let value: E164Number | null = '';

	// Validity
	let valid = true;

	// Optional - Extended details about the parsed phone number
	let detailedValue: DetailedValue | null = null;

	onMount(() => {
		getUser();
	});

	const getUser = async () => {
		//The URL has no ID if the user is on their own profile
		const userId = $page.url.searchParams.get('id');
		if (!userId) isUser = true;
		else isUser = userId === localStorage.getItem('userId');

		const { res, json } = await fetchRequest('GET', isUser ? 'user' : `users?id=${userId}`);
		user = isUser ? json : json.results[0];
		userEdit = user;

		if (userEdit.bio === null) userEdit.bio = '';
		if (userEdit.website === null) userEdit.website = '';

		if (user.profile_image) profileImagePreview = `${env.PUBLIC_API_URL}${user.profile_image}`;
		if (user.banner_image) bannerImagePreview = `${env.PUBLIC_API_URL}${user.banner_image}`;

		document.title = `${user.username}'s profile`;
	};

	const updateProfile = async () => {
		const imageToSend = await blobifyImages(profileImagePreview);
		const bannerImageToSend = await blobifyImages(bannerImagePreview);

		const formData = new FormData();
		formData.append('username', userEdit.username);
		formData.append('bio', userEdit.bio || '');
		formData.append('website', userEdit.website || '');
		formData.append('contact_email', userEdit.contact_email || '');
		formData.append('contact_phone', userEdit.contact_phone || '');

		if (bannerImagePreview !== '') formData.append('banner_image', bannerImageToSend);
		if (profileImagePreview !== DefaultPFP) formData.append('profile_image', imageToSend);

		const { res, json } = await fetchRequest('POST', `user/update`, formData, true, false);
		if (res.ok) {
			user = userEdit;
			isEditing = false;
			pfpStore.set(`${imageToSend.name}${Math.floor(Math.random() * 1000000)}`);
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
		oldBannerImagePreview = bannerImagePreview;
		if (e.target.files.length > 0) bannerImagePreview = URL.createObjectURL(e.target.files[0]);
		currentlyCroppingBanner = true;
	};

	let imageToBeCropped: any;

	$: if (currentlyCroppingProfile) imageToBeCropped = profileImagePreview;
	else if (currentlyCroppingBanner) imageToBeCropped = bannerImagePreview;
</script>

{#if currentlyCroppingProfile || currentlyCroppingBanner}
	<!-- Cropp image -->
	<CropperModal
		confirmAction={() => {
			if (currentlyCroppingProfile) profileImagePreview = croppedImage;
			else if (currentlyCroppingBanner) bannerImagePreview = croppedImage;

			currentlyCroppingProfile = false;
			currentlyCroppingBanner = false;
		}}
		cancelAction={() => {
			currentlyCroppingProfile = false;
			currentlyCroppingBanner = false;
			profileImagePreview = oldProfileImagePreview;
		}}
		bind:croppedImage
		bind:currentlyCroppingProfile
		bind:image={imageToBeCropped}
	/>
{/if}

<!-- Viewing someone's profile -->
<Layout centered Class="bg-white dark:bg-darkobject shadow">
	{#if !isEditing}
		<div class="relative w-full">
			<img
				src={bannerImagePreview || DefaultBanner}
				class="w-full cover aspect-ratio-5"
				alt="banner"
			/>

			{#if isUser}
				<Button
					action={() => (isEditing = true)}
					Class="absolute right-0 top-0 p-3 m-4 transition-all bg-gray-200 dark:bg-darkobject hover:brightness-95 active:brightness-90"
				>
					<div class="text-gray-800 dark:text-gray-200">
						<Fa icon={faPen} />
					</div>
				</Button>
			{/if}
			<Button
				action={() => goto($nav?.from?.url.pathname || '/')}
				Class="absolute left-0 top-0 p-3 m-4 transition-all bg-gray-200 dark:bg-darkobject hover:brightness-95 active:brightness-90"
			>
				<div class="text-gray-800 dark:text-gray-200">
					<Fa icon={faArrowLeft} />
				</div>
			</Button>
		</div>
		<div class="flex justify-around w-full max-w-[800px]">
			<img
				src={profileImagePreview}
				class="-translate-y-10 h-36 w-36 z-10 rounded-full profile"
				alt="avatar"
				id="avatar"
			/>
			<div class="z-0 dark:bg-darkobject dark:text-darkmodeText w-[60%] py-6">
				<div class="text-xl text-primary dark:text-secondary font-bold max-w-[600px] break-words">
					{user.username}
				</div>
				<p class=" whitespace-pre-wrap">
					{user.bio || $_('This user has no bio')}
				</p>
				<StatusMessage Class="" bind:status />
			</div>
			<div class="dark:text-darkmodeText py-6">
				<div class="text-primary dark:text-secondary font-bold">{$_('Contact Information')}</div>
				<a class={``} href={user.website || $_('None provided')}>
					{$_('Website')}: {user.website || ''}
				</a>
				<!-- <div>Phone number</div> -->
				<p class="">
					{$_('Phone number')}: {user.contact_phone || $_('None provided')}
				</p>
				<p class="">
					{$_('E-mail')}: {user.contact_email || $_('None provided')}
				</p>
			</div>
		</div>
		<!-- Editing your own profile -->
	{:else}
		<!-- Banner Image -->
		<label for="file-ip-2" class="bg-gray-200 w-full h-[40%] cover">
			<img
				src={currentlyCroppingBanner ? oldBannerImagePreview : bannerImagePreview || DefaultBanner}
				class="w-full cover transition-all filter hover:grayscale-[70%] hover:bg-gray-200 dark:bg-darkobject dark:hover:brightness-[120%] backdrop-grayscale"
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
			class="w-full bg-white shadow rounded p-8 dark:bg-darkobject dark:text-darkmodeText"
			on:submit|preventDefault={() => {}}
		>
			<label for="file-ip-1" class="inline">
				<!-- Profile PIcture -->
				<img
					src={currentlyCroppingProfile ? oldProfileImagePreview : profileImagePreview}
					class="mt-6 h-36 w-36 inline rounded-full transition-all filter hover:grayscale-[70%] hover:bg-gray-200 dark:bg-darkobject dark:hover:brightness-[120%] backdrop-grayscale"
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
				<button
					on:click={() => (currentlyEditing = 'name')}
					class="mt-6 pt-4 pb-4 pl-4 pr-4 text-center transition transition-color cursor-pointer hover:bg-gray-200 dark:bg-darkobject dark:hover:brightness-[120%] rounded-xl inline"
				>
					{$_(userEdit.username || 'Add Username')}
				</button>
			{/if}

			{#if currentlyEditing === 'phone'}
				<div class="wrapper">
					<select
						class="country-select {!valid ? 'invalid' : ''}"
						aria-label="Default select example"
						name="Country"
						bind:value={selectedCountry}
					>
						<option value={null} hidden={selectedCountry !== null}>Please select</option>
						{#each normalizedCountries as currentCountry (currentCountry.id)}
							<option
								value={currentCountry.iso2}
								selected={currentCountry.iso2 === selectedCountry}
								aria-selected={currentCountry.iso2 === selectedCountry}
							>
								{currentCountry.iso2} (+{currentCountry.dialCode})
							</option>
						{/each}
					</select>
					<TelInput
						bind:country={selectedCountry}
						bind:value={userEdit.contact_phone}
						bind:valid
						bind:detailedValue
						class="basic-tel-input {!valid ? 'invalid' : ''}"
					/>
				</div>

				<!-- <TextInput
					autofocus
					onBlur={() => (currentlyEditing = null)}
					label={'Phone Number'}
					bind:value={userEdit.contact_phone}
					Class="mt-6 pt-8 pb-8 inline"
				/> -->
			{:else}
				<button
					on:click={() => (currentlyEditing = 'phone')}
					class="mt-6 pt-4 pb-4 pl-4 pr-4 text-center transition transition-color cursor-pointer hover:bg-gray-200 dark:bg-darkobject dark:hover:brightness-[120%] rounded-xl inline"
				>
					{$_(userEdit.contact_phone || 'Add phone number')}
				</button>
			{/if}

			{#if currentlyEditing === 'web'}
				<TextInput
					autofocus
					onBlur={() => (currentlyEditing = null)}
					label={'Website'}
					bind:value={userEdit.website}
					Class="pt-8 pb-8"
				/>
			{:else}
				<button
					on:click={() => (currentlyEditing = 'web')}
					class="pt-4 pb-4 pl-4 pr-4 text-center transition transition-color cursor-pointer hover:bg-gray-200 dark:bg-darkobject dark:hover:brightness-[120%] rounded-xl"
				>
					{userEdit.website || $_('Add Website')}
				</button>
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
				<div
					on:click={() => (currentlyEditing = 'bio')}
					on:keydown
					role="button"
					tabindex="0"
					class="pt-8 pb-8 pl-4 pr-4 transition transition-color cursor-pointer hover:bg-gray-200 dark:bg-darkobject dark:hover:brightness-[120%] rounded-xl whitespace-pre-wrap"
				>
					{userEdit.bio || $_('Add Bio')}
				</div>
			{/if}

			<StatusMessage Class="mt-4" bind:status />
			<div class="flex justify-end gap-2">
				<Button
					Class=""
					action={() => {
						isEditing = false;
						profileImagePreview = oldProfileImagePreview;
					}}>{$_('Cancel')}</Button
				>
				<Button Class="" action={updateProfile}>{$_('Save changes')}</Button>
			</div>
		</form>
	{/if}

	{#if $page.url.searchParams.get('delegate_id')}
		<History history={Number($page.url.searchParams.get('delegate_id'))} groupId={1} />
	{/if}
</Layout>

<style>
	img.cover {
		aspect-ratio: 5;
		/* width: 100%; */
	}

	img.profile {
		width: 100px;
		height: 100px;
	}

	.aspect-ratio-5 {
		aspect-ratio: 5;
	}

	.bg-semi-transparent {
		background-color: rgb(209, 213, 219);
	}

	.wrapper :global(.basic-tel-input) {
		height: 32px;
		padding-left: 12px;
		padding-right: 12px;
		border-radius: 6px;
		border: 1px solid;
		outline: none;
	}

	.wrapper :global(.country-select) {
		height: 36px;
		padding-left: 12px;
		padding-right: 12px;
		border-radius: 6px;
		border: 1px solid;
		outline: none;
	}

	.wrapper :global(.invalid) {
		border-color: red;
	}
</style>

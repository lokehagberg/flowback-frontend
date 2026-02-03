<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { User } from '$lib/User/interfaces';
	import Layout from '$lib/Generic/Layout.svelte';
	import DefaultPFP from '$lib/assets/abstract-user-flat-4.svg';
	import DefaultBanner from '$lib/assets/default_banner_user.png';
	import { _ } from 'svelte-i18n';
	import Button from '$lib/Generic/Button.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { blobifyImages, getUserInfo } from '$lib/Generic/GenericFunctions';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import CropperModal from '$lib/Generic/Cropper/CropperModal.svelte';
	import { env } from '$env/dynamic/public';
	import Fa from 'svelte-fa';
	import {
		faArrowLeft,
		faPen,
		faPaperPlane
	} from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import { TelInput, normalizedCountries } from 'svelte-tel-input';
	import type { DetailedValue, CountryCode } from 'svelte-tel-input/types';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import { chatOpenStore, chatPartnerStore } from '$lib/Chat/functions';
	import { getUserChannelId } from '$lib/Chat/functions';
	import Loader from '$lib/Generic/Loader.svelte';
	import { userStore } from '$lib/User/interfaces';
	import History from '../../lib/Delegation/History.svelte';

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
		currentlyCroppingProfile: boolean = false,
		currentlyCroppingBanner = false,
		oldProfileImagePreview = '',
		oldBannerImagePreview = '',
		croppedImage: string,
		loading = false,
		// Any Country Code Alpha-2 (ISO 3166)
		selectedCountry: CountryCode | null = 'SE',
		// Validity
		valid = true,
		// Optional - Extended details about the parsed phone number
		detailedValue: DetailedValue | null = null;

	const blankSymbol = '___';

	onMount(() => {
		getUser();
	});

	const getUser = async () => {
		//The URL has no ID if the user is on their own profile
		const userId = $page.url.searchParams.get('id');
		if (!userId) isUser = true;
		else isUser = userId === ($userStore?.id || -1).toString();

		const { res, json } = await fetchRequest(
			'GET',
			isUser ? 'user' : `users?id=${userId}`
		);
		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Could not fetch user',
				success: false
			});
			return;
		}
		user = isUser ? json : json?.results[0];
		userEdit = user;

		if (userEdit.bio === null || userEdit.bio === blankSymbol)
			userEdit.bio = '';
		if (userEdit.website === null || userEdit.website === blankSymbol)
			userEdit.website = '';

		if (user.profile_image)
			profileImagePreview = `${env.PUBLIC_API_URL}${user.profile_image}`;
		if (user.banner_image)
			bannerImagePreview = `${env.PUBLIC_API_URL}${user.banner_image}`;

		if (!user.contact_email || userEdit.contact_email === 'a@a.com')
			userEdit.contact_email = '';
		if (!user.contact_phone || userEdit.contact_phone === '+4646464646')
			userEdit.contact_phone = '';

		document.title = `${user.username}'s profile`;
	};

	const editUser = async () => {
		loading = true;
		const imageToSend = await blobifyImages(profileImagePreview);
		const bannerImageToSend = await blobifyImages(bannerImagePreview);

		const formData = new FormData();
		formData.append('username', userEdit.username);
		formData.append('bio', userEdit.bio === '' ? blankSymbol : userEdit.bio);
		formData.append(
			'website',
			userEdit.website === '' ? blankSymbol : userEdit.website
		);
		formData.append(
			'contact_email',
			userEdit.contact_email === '' ? `a@a.com` : userEdit.contact_email
		);
		formData.append(
			'contact_phone',
			userEdit.contact_phone === '' ? `+4646464646` : userEdit.contact_phone
		);

		if (bannerImagePreview !== '')
			formData.append('banner_image', bannerImageToSend);
		if (profileImagePreview !== DefaultPFP)
			formData.append('profile_image', imageToSend);

		const { res, json } = await fetchRequest(
			'POST',
			`user/update`,
			formData,
			true,
			false
		);

		loading = false;

		if (!res.ok) {
			const message =
				json.detail[Object.keys(json.detail)[0]][0] ||
				'Could not update profile';

			ErrorHandlerStore.set({ message, success: false });
			return;
		}

		// Required to update user properly
		const updatedUser = await getUserInfo();
		userStore.set(updatedUser);
		user = updatedUser;

		isEditing = false;
		ErrorHandlerStore.set({
			message: 'Profile successfully updated',
			success: true
		});
	};

	const handleCropProfileImage = async (e: any) => {
		//Type string, for preview image
		oldProfileImagePreview = profileImagePreview;
		if (e.target.files.length > 0)
			profileImagePreview = URL.createObjectURL(e.target.files[0]);
		currentlyCroppingProfile = true;
	};

	const handleCropBanner = async (e: any) => {
		//Type string, for preview image
		oldBannerImagePreview = bannerImagePreview;
		if (e.target.files.length > 0)
			bannerImagePreview = URL.createObjectURL(e.target.files[0]);
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
			<Button
				onClick={() => {
					if (window.history.length > 1) {
						window.history.back();
					} else {
						goto('/');
					}
				}}
				Class="fixed p-3 m-4 transition-all bg-gray-200 dark:bg-darkobject hover:brightness-95 active:brightness-90"
			>
				<div class="text-gray-800 dark:text-gray-200">
					<Fa icon={faArrowLeft} />
				</div>
			</Button>
			<img
				src={bannerImagePreview || DefaultBanner}
				class="w-full cover aspect-ratio-5"
				alt="banner"
			/>

			{#if isUser}
				<Button
					onClick={() => (isEditing = true)}
					Class="absolute right-0 top-0 p-3 m-4 transition-all bg-gray-200 dark:bg-darkobject hover:brightness-95 active:brightness-90"
					id="edit-profile-button"
				>
					<div class="text-gray-800 dark:text-gray-200">
						<Fa icon={faPen} />
					</div>
				</Button>
			{/if}
		</div>
		<div class="flex justify-around w-full max-w-[850px]">
			<img
				src={profileImagePreview}
				class="-translate-y-10 h-36 w-36 z-10 rounded-full profile border border-gray-300"
				alt="avatar"
				id="avatar"
			/>
			<div
				class="z-0 dark:bg-darkobject dark:text-darkmodeText w-[60%] py-6 px-4"
			>
				<div
					class="text-xl text-primary dark:text-secondary font-bold max-w-[600px] break-words"
				>
					{user.username}
				</div>
				<p class=" whitespace-pre-wrap">
					{user.bio === blankSymbol ? $_('This user has no bio') : user.bio}
				</p>
			</div>
			<div class="dark:text-darkmodeText py-6 w-[30%]">
				<div class="text-primary dark:text-secondary font-bold">
					{$_('Contact Information')}
					{#await getUserChannelId(user.id) then channelId}
						{#if channelId}
							<button
								on:click={() => {
									chatOpenStore.set(true);
									chatPartnerStore.set(channelId);
								}}
								Class="text-primary"
							>
								<Fa icon={faPaperPlane} rotate="60" />
							</button>
						{/if}
					{/await}
				</div>

				{#if user.website && user.website !== blankSymbol && user.website !== ''}
					<a
						href={user.website.startsWith('http://') ||
						user.website.startsWith('https://')
							? user.website
							: 'https://' + user.website}
						target="_blank"
						rel="noopener noreferrer"
					>
						{$_('Website')}:
						{user.website}
					</a>
				{:else}
					<span>
						{$_('Website')}:
						{$_('None provided')}
					</span>
				{/if}
				<p class="">
					{$_('Phone number')}: {user.contact_phone === '+4646464646' ||
					user.contact_phone === ''
						? $_('None provided')
						: user.contact_phone}
				</p>
				<p class="">
					{$_('E-mail')}: {user.contact_email === 'a@a.com' ||
					user.contact_email === ''
						? $_('None provided')
						: user.contact_email}
				</p>
			</div>
		</div>
		<!-- Editing your own profile -->
	{:else}
		<Loader bind:loading>
			<!-- Banner Image -->
			<label for="file-ip-2" class="bg-gray-200 w-full h-[40%] cover">
				<img
					src={currentlyCroppingBanner
						? oldBannerImagePreview
						: bannerImagePreview || DefaultBanner}
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
				class="bg-white w-full p-8 flex flex-col items-center justify-center dark:bg-darkobject dark:text-darkmodeText"
				on:submit|preventDefault={editUser}
			>
				<div
					class="flex flex-row items-center justify-center gap-6 pb-6 w-full"
				>
					<label for="file-ip-1" class="inline">
						<!-- Profile Picture -->
						<img
							src={currentlyCroppingProfile
								? oldProfileImagePreview
								: profileImagePreview}
							class="mt-6 h-36 w-36 inline rounded-full border border-gray-300 transition-all filter hover:grayscale-[70%] hover:bg-gray-200 dark:bg-darkobject dark:hover:brightness-[120%] backdrop-grayscale"
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

					<div class="flex flex-col gap-1 w-[40%]">
						<TextInput
							autofocus
							onBlur={() => (currentlyEditing = null)}
							label={'Name'}
							bind:value={userEdit.username}
							Class="p-2 text-left"
						/>

						<TextInput
							autofocus
							onBlur={() => (currentlyEditing = null)}
							label={'Website'}
							bind:value={userEdit.website}
							Class="p-2 text-left"
						/>

						<div class="wrapper">
							<select
								class="country-select {!valid ? 'invalid' : ''}"
								aria-label="Default select example"
								name="Country"
								bind:value={selectedCountry}
							>
								<option value={null} hidden={selectedCountry !== null}
									>Please select</option
								>
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

						<TextInput
							autofocus
							onBlur={() => (currentlyEditing = null)}
							label={'Mail'}
							type="email"
							bind:value={userEdit.contact_email}
							Class="p-2 text-left"
						/>

						<TextArea
							autofocus
							onBlur={() => (currentlyEditing = null)}
							label={'Bio'}
							bind:value={userEdit.bio}
							Class="p-2 text-left"
							inputClass="whitespace-pre-wrap"
						/>
					</div>
				</div>

				<div class="flex gap-2 w-[50%]">
					<Button
						Class="flex-1"
						buttonStyle="warning-light"
						onClick={() => {
							isEditing = false;
							// profileImagePreview = oldProfileImagePreview;
							getUser();
						}}>{$_('Cancel')}</Button
					>
					<Button Class="flex-1" buttonStyle="primary-light" type="submit">
						{$_('Save changes')}</Button
					>
				</div>
			</form>
		</Loader>
	{/if}

	{#if $page.url.searchParams.get('delegate_id')}
		<History
			history={Number($page.url.searchParams.get('delegate_id'))}
			groupId={Number($page.url.searchParams.get('group_id'))}
		/>
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

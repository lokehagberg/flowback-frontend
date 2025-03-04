<script lang="ts">
	import Button from '$lib/Generic/Button.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Fa from 'svelte-fa';
	import { faPaperPlane } from '@fortawesome/free-solid-svg-icons/faPaperPlane';
	import { fetchRequest } from '$lib/FetchRequest';
	import ImageUpload from '$lib/Generic/FileUpload.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { _ } from 'svelte-i18n';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import { blobifyImages, type StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import Modal from '$lib/Generic/Modal.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { faUser } from '@fortawesome/free-solid-svg-icons/faUser';
	import { faFileImage } from '@fortawesome/free-solid-svg-icons/faFileImage';
	import { goto } from '$app/navigation';
	import { becomeMemberOfGroup } from '$lib/Blockchain_v1_Ethereum/javascript/rightToVote';
	import { env } from '$env/dynamic/public';
	import type { poppup } from '$lib/Generic/Poppup';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';

	export let Class = '';

	//This file is used for both creating and editing groups
	let name: string,
		description: string,
		image: string,
		coverImage: string,
		useInvite = false,
		publicGroup = true,
		hiddenGroup = false,
		loading = false,
		poppup: poppup;

	//This page also supports the edit of groups
	const groupToEdit = $page.url.searchParams.get('group') || $page.params.groupId;
	let status: StatusMessageInfo;
	let DeleteGroupModalShow = false;

	//This function is also used for group editing
	const createGroup = async () => {
		loading = true;
		const formData = new FormData();

		//This must be less than or equal to 2147483647
		const blockchain_id = Math.floor(Math.random() * 2147483647);

		//Formdata used to transfer images
		formData.append('name', name);
		formData.append('description', description);
		formData.append('direct_join', (!useInvite).toString());
		formData.append('public', publicGroup.toString());
		formData.append('blockchain_id', blockchain_id.toString());
		formData.append('hide_poll_users', hiddenGroup.toString());

		if (image) formData.append('image', await blobifyImages(image));
		if (coverImage) formData.append('cover_image', await blobifyImages(coverImage));

		let api = groupToEdit ? `group/${groupToEdit}/update` : 'group/create';
		const { res, json } = await fetchRequest('POST', api, formData, true, false);

		if (!res.ok) {
			status = statusMessageFormatter(res, json);
			loading = false;
			return;
		}

		if (groupToEdit === null || groupToEdit === undefined) {
			const { res } = await fetchRequest('POST', `group/${json}/tag/create`, {
				name: 'Uncategorised' //Default
			});

			if (res.ok) {
				if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE') becomeMemberOfGroup(blockchain_id);
				goto(`/groups/${json}`);
			} else status = statusMessageFormatter(res, json);
		} else goto(`/groups/${groupToEdit}`);
		loading = false;
	};

	const deleteGroup = async () => {
		const { res } = await fetchRequest('POST', `group/${groupToEdit}/delete`);

		if (!res.ok) {
			poppup = { message: 'Could not delete group', success: false };
			return;
		}

		//Rederict to group
		if (res.ok) goto('/groups');
	};

	const getGroupToEdit = async () => {
		//TODO: detail is outdated
		const { res, json } = await fetchRequest('GET', `group/${groupToEdit}/detail`);
		name = json.name;
		description = json.description;
		useInvite = !json.direct_join;
		publicGroup = json.public;

		if (json.image) image = `${env.PUBLIC_API}${json.image}`;
		if (json.cover_image) coverImage = `${env.PUBLIC_API}${json.cover_image}`;
	};

	onMount(() => {
		if (groupToEdit) {
			getGroupToEdit();
		}
	});
</script>

<svelte:head>
	<title>{$_('Creating a Group')}</title>
</svelte:head>

<form
	on:submit|preventDefault={createGroup}
	class={`dark:text-darkmodeText bg-white dark:bg-darkobject ${Class}`}
>
	<Loader bind:loading>
		<div class="flex flex-col gap-6">
			{#if !groupToEdit}
				<h1 class="text-2xl">{$_('Create a Group')}</h1>
			{/if}

			<TextInput label="Title" bind:value={name} required />
			<TextArea label="Description" bind:value={description} />
			<ImageUpload icon={faUser} isProfile bind:imageString={image} label="Upload Image" />
			<ImageUpload icon={faFileImage} bind:imageString={coverImage} label="Upload Banner" />

			{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
				<RadioButtons
					bind:Yes={useInvite}
					label={'Invitation Required?'}
					Class="flex items-center justify-between gap-3 w-full"
				/>
				<RadioButtons
					bind:Yes={publicGroup}
					label={'Public?'}
					Class="flex items-center justify-between gap-3 w-full"
				/>
				<RadioButtons
					bind:Yes={hiddenGroup}
					label={'Hide proposal creator?'}
					Class="flex items-center justify-between gap-3 w-full"
				/>
			{/if}

			<StatusMessage bind:status />

			<div class="flex gap-4">
				<Button type="submit" disabled={loading} buttonStyle="primary-light" Class="w-1/2"
					><div class="flex justify-center gap-3 items-center">
						{$_(groupToEdit ? 'Update' : 'Create Group')}
					</div>
				</Button>
				{#if groupToEdit !== null && !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
					<Modal bind:open={DeleteGroupModalShow}>
						<div slot="header">{$_('Deleting group')}</div>
						<div slot="body">{$_('Are you sure you want to delete this group?')}</div>
						<div slot="footer">
							<div class="flex justify-center gap-16">
								<Button action={deleteGroup} buttonStyle="warning">{$_('Yes')}</Button><Button
									action={() => (DeleteGroupModalShow = false)}
									Class="bg-gray-400 w-1/2">{$_('Cancel')}</Button
								>
							</div>
						</div>
					</Modal>
					<Button
						buttonStyle="warning-light"
						Class="w-1/2"
						action={() => (DeleteGroupModalShow = true)}>{$_('Delete Group')}</Button
					>
				{/if}
			</div>
		</div>
	</Loader>
</form>

<Poppup bind:poppup />

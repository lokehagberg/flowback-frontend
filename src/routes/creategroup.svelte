<script lang="ts">
	import RadioButtons from '../lib/Generic/RadioButtons.svelte';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faPaperPlane } from '@fortawesome/free-solid-svg-icons/faPaperPlane';
	import { fetchRequest } from '$lib/FetchRequest';
	import ImageUpload from '$lib/Generic/ImageUpload.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { _ } from 'svelte-i18n';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import Modal from '$lib/Generic/Modal.svelte';

	let name = 'Default Name',
		description = 'Default Descritption',
		image: File,
		coverImage: File,
		directJoin = true,
		publicGroup = true;

	//This page also supports the edit of groups
	const groupToEdit = $page.url.searchParams.get('group');
	let status: StatusMessageInfo;
	let DeleteGroupModalShow = false;

	const createGroup = async () => {
		const formData = new FormData();

		formData.append('name', name);
		formData.append('description', description);
		formData.append('image', image);
		formData.append('cover_image', coverImage);
		formData.append('direct_join', directJoin.toString());
		formData.append('public', publicGroup.toString());

		let api = groupToEdit === null ? 'group/create' : `group/${groupToEdit}/update`;
		const { res, json } = await fetchRequest('POST', api, formData, true, false);

		if (res.ok) status = { message: 'Success', success: true };
		else if (json.detail) {
			const errorMessage = json.detail[Object.keys(json.detail)[0]][0];
			if (errorMessage) status = { message: errorMessage, success: false };
		}
	};

	const deleteGroup = async () => {
		const { res } = await fetchRequest('POST', `group/${groupToEdit}/delete`);

		//Rederict to group
		console.log(res);
		if (res.ok) {
			window.location.href = '/groups'
		}
	};

	onMount(() => {
		if (groupToEdit !== null) {
		}
	});
</script>

<Layout centering={true}>
	<form
		on:submit|preventDefault={createGroup}
		class="flex items-start justify-center gap-8 mt-8 ml-8 mr-8 w-full"
	>
		<div class="bg-white p-6 shadow-xl flex flex-col gap-6 w-2/3">
			<h1 class="text-2xl">{$_('Create a Group')}</h1>
			<TextInput label="Title" bind:value={name} required={true} />
			<TextArea label="Description" bind:value={description} required={true} />
			<ImageUpload bind:image label="Upload Image" />
			<ImageUpload bind:image={coverImage} label="Upload Cover Image" isCover={true} />
			<RadioButtons bind:Yes={directJoin} label={'Direct Join'} />
			<RadioButtons bind:Yes={publicGroup} label={'Public'} />

			{#if groupToEdit !== null}
				<Modal bind:open={DeleteGroupModalShow}>
					<div slot="header">{$_('Deleting group')}</div>
					<div slot="body">{$_('Are you sure you want to delete this group?')}</div>
					<div slot="footer">
						<div class="flex justify-center gap-16">
							<ButtonPrimary action={deleteGroup} Class="bg-red-500">{$_('Yes')}</ButtonPrimary
							><ButtonPrimary action={() => (DeleteGroupModalShow = false)} Class="bg-gray-400 w-1/2"
								>{$_('Cancel')}</ButtonPrimary
							>
						</div>
					</div>
				</Modal>
				<ButtonPrimary action={() => DeleteGroupModalShow=true}>{$_('Delete Group')}</ButtonPrimary>
			{/if}

			<StatusMessage bind:status />
			<ButtonPrimary type="submit"
				><div class="flex justify-center gap-3 items-center">
					<Fa icon={faPaperPlane} />{$_('Create Group')}
				</div>
			</ButtonPrimary>
		</div>
	</form>
</Layout>

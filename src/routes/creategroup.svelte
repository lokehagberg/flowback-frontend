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

	let name = 'Default Name',
		description = 'Default Descritption',
		image: File,
		coverImage: File,
		directJoin = true,
		publicGroup = true;

	let status: StatusMessageInfo;

	const createGroup = async () => {
		const formData = new FormData();

		formData.append('name', name);
		formData.append('description', description);
		formData.append('image', image);
		formData.append('cover_image', coverImage);
		formData.append('direct_join', directJoin.toString());
		formData.append('public', publicGroup.toString());

		if (groupToEdit === null) {
			const res = await fetchRequest('POST', 'group/create', formData, true, false);
			console.log(res);
			status = res.res.ok
				? { message: 'Group created', success: true }
				: { message: "Couldn't create group", success: false };
		}
		if (groupToEdit !== null) {
			const res = await fetchRequest('POST', `group/${groupToEdit}/update`, formData, true, false);
			console.log(res);
			status = res.res.ok
				? { message: 'Group edited', success: true }
				: { message: "Couldn't edit group", success: false };
		}
	};

	//This page also supports the edit of groups
	const groupToEdit = $page.url.searchParams.get('group');

	const deleteGroup = async () => {
		const { res } = await fetchRequest('POST', `group/${groupToEdit}/delete`);

		//Rederict to group
		console.log(res);
		if (res.ok) {
			// window.location.href = ''
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
			<TextInput label="Title" bind:value={name} />
			<TextArea label="Description" bind:value={description} />
			<ImageUpload bind:image label="Upload Image" />
			<ImageUpload bind:image={coverImage} label="Upload Cover Image" isCover={true} />
			<RadioButtons bind:Yes={directJoin} label={'Direct Join'} />
			<RadioButtons bind:Yes={publicGroup} label={'Public'} />

			{#if groupToEdit !== null}
				<ButtonPrimary action={deleteGroup}>{$_('Delete Group')}</ButtonPrimary>
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

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

	let name = 'Default Name',
		description = 'Default Descritption',
		image: File,
		coverImage: File,
		directJoin = true,
		publicGroup = true;

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
		}
		if (groupToEdit !== null) {
			const res = await fetchRequest('POST', `group/${groupToEdit}/update`, formData, true, false);
			console.log(res);
		}
	};

	//This page also supports the edit of groups
	const groupToEdit = $page.url.searchParams.get('group');

	const deleteGroup = () => {
		fetchRequest('POST', `group/${groupToEdit}/delete`);
	};

	onMount(() => {
		if (groupToEdit !== null) {
		}
	});
</script>

<Layout centering={true}>
	<form
		on:submit|preventDefault={createGroup}
		class="flex items-start justify-center gap-8 mt-24 ml-8 mr-8"
	>
		<div class="bg-white p-6 shadow-xl flex flex-col gap-6 w-2/3">
			<h1 class="text-2xl">Create a Group</h1>
			<TextInput label="Title" bind:value={name} />
			<TextArea label="Description" bind:value={description} />
			<ImageUpload bind:image label="Upload Image" />
			<ImageUpload bind:image={coverImage} label="Upload Cover Image" isCover={true} />
			<RadioButtons bind:Yes={directJoin} label={'Direct Join'} />
			<RadioButtons bind:Yes={publicGroup} label={'Public'} />

			{#if groupToEdit !== null}
				<ButtonPrimary action={deleteGroup}>Delete Group</ButtonPrimary>
			{/if}
			<ButtonPrimary type="submit"
				><div class="flex justify-center gap-3 items-center">
					<Fa icon={faPaperPlane} />Create Group
				</div>
			</ButtonPrimary>
		</div>
	</form>
</Layout>

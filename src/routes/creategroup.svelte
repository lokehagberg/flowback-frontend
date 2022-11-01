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
	import Loader from '$lib/Generic/Loader.svelte';

	let name: string,
		description: string,
		image: File,
		coverImage: File,
		directJoin = true,
		publicGroup = true,
		loading = false;

	//This page also supports the edit of groups
	const groupToEdit = $page.url.searchParams.get('group');
	let status: StatusMessageInfo;
	let DeleteGroupModalShow = false;

	const createGroup = async () => {
		loading = true;
		const formData = new FormData();

		formData.append('name', name);
		formData.append('description', description);
		formData.append('image', image);
		formData.append('cover_image', coverImage);
		formData.append('direct_join', directJoin.toString());
		formData.append('public', publicGroup.toString());

		let api = groupToEdit === null ? 'group/create' : `group/${groupToEdit}/update`;
		const { res, json } = await fetchRequest('POST', api, formData, true, false);

		if (res.ok) {
			const { res } = await fetchRequest('POST', `group/${json}/tag/create`, {
				tag_name: 'Okategoriserad' //Default
			});
			if (res.ok) {
				status = { message: 'Success', success: true };
				window.location.href = `/groups/${json}`;
			} else if (json.detail) {
				const errorMessage = json.detail[Object.keys(json.detail)[0]][0];
				if (errorMessage) status = { message: errorMessage, success: false };
			}
		} else if (json.detail) {
			const errorMessage = json.detail[Object.keys(json.detail)[0]][0];
			if (errorMessage) status = { message: errorMessage, success: false };
		}

		loading = false;
	};

	const deleteGroup = async () => {
		const { res } = await fetchRequest('POST', `group/${groupToEdit}/delete`);

		//Rederict to group
		console.log(res);
		if (res.ok) {
			window.location.href = '/groups';
		}
	};

	onMount(() => {
		if (groupToEdit !== null) {
		}
	});
</script>

<Layout centering>
	<Loader bind:loading>
		<form
			on:submit|preventDefault={createGroup}
			class="lg:absolute left-1/2 lg:-translate-x-1/2 lg:flex items-start lg:justify-center gap-8 md:mt-8 w-full lg:w-[1000px]"
		>
			<div class="bg-white p-6 shadow-xl flex flex-col gap-6 w-2/3 md:w-full">
				<h1 class="text-2xl">{$_('Create a Group')}</h1>
				<TextInput label="Title" bind:value={name} required />
				<TextArea label="Description" bind:value={description} required />
				<ImageUpload bind:image label="Upload Image, recomended ratio 1:1" />
				<ImageUpload
					bind:image={coverImage}
					label="Upload Cover Image, recomended ratio 4:1"
					isCover
				/>
				<RadioButtons bind:Yes={directJoin} label={'Direct Join?'} />
				<RadioButtons bind:Yes={publicGroup} label={'Public?'} />

				{#if groupToEdit !== null}
					<Modal bind:open={DeleteGroupModalShow}>
						<div slot="header">{$_('Deleting group')}</div>
						<div slot="body">{$_('Are you sure you want to delete this group?')}</div>
						<div slot="footer">
							<div class="flex justify-center gap-16">
								<ButtonPrimary action={deleteGroup} Class="bg-red-500">{$_('Yes')}</ButtonPrimary
								><ButtonPrimary
									action={() => (DeleteGroupModalShow = false)}
									Class="bg-gray-400 w-1/2">{$_('Cancel')}</ButtonPrimary
								>
							</div>
						</div>
					</Modal>
					<ButtonPrimary action={() => (DeleteGroupModalShow = true)}
						>{$_('Delete Group')}</ButtonPrimary
					>
				{/if}

				<StatusMessage bind:status />
				<ButtonPrimary type="submit" disabled={loading}
					><div class="flex justify-center gap-3 items-center">
						<Fa icon={faPaperPlane} />{$_('Create Group')}
					</div>
				</ButtonPrimary>
			</div>
		</form>
	</Loader>
</Layout>

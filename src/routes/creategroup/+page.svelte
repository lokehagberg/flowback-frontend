<script lang="ts">
	import RadioButtons from '../../lib/Generic/RadioButtons.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faPaperPlane } from '@fortawesome/free-solid-svg-icons/faPaperPlane';
	import { fetchRequest } from '$lib/FetchRequest';
	import ImageUpload from '$lib/Generic/ImageUpload.svelte';
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
	import CropperModal from '$lib/Generic/Cropper/CropperModal.svelte';
	import { goto } from '$app/navigation';
	import { becomeMemberOfGroup } from '$lib/Blockchain/javascript/rightToVote';
	import { env } from "$env/dynamic/public";

	let name: string,
		description: string,
		image: string,
		coverImage: string,
		useInvite = false,
		publicGroup = true,
		hiddenGroup = false,
		loading = false;

	//This page also supports the edit of groups
	const groupToEdit = $page.url.searchParams.get('group');
	let status: StatusMessageInfo;
	let DeleteGroupModalShow = false;

	//This function is also used for group editing
	const createGroup = async () => {
		loading = true;
		const formData = new FormData();
		const blockchain_id = Math.floor(
			(1 + Math.random()) * 1000000 * name.length * description.length
		);

		formData.append('name', name);
		formData.append('description', description);
		formData.append('direct_join', (!useInvite).toString());
		formData.append('public', publicGroup.toString());
		formData.append('blockchain_id', blockchain_id.toString());
		formData.append('hide_poll_users', hiddenGroup.toString());

		if (image) formData.append('image', await blobifyImages(image));
		if (coverImage) formData.append('cover_image', await blobifyImages(coverImage));

		let api = groupToEdit === null ? 'group/create' : `group/${groupToEdit}/update`;
		const { res, json } = await fetchRequest('POST', api, formData, true, false);

		if (!res.ok) {
			status = statusMessageFormatter(res, json);
			loading = false;
			return;
		}

		if (groupToEdit === null) {
			const { res } = await fetchRequest('POST', `group/${json}/tag/create`, {
				name: 'Uncategorised' //Default
			});

			if (res.ok) {
				if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE')
					becomeMemberOfGroup(blockchain_id);
				goto(`/groups/${json}`);
			} else status = statusMessageFormatter(res, json);
		} else goto(`/groups/${groupToEdit}`);
		loading = false;
	};

	const deleteGroup = async () => {
		const { res } = await fetchRequest('POST', `group/${groupToEdit}/delete`);

		//Rederict to group
		if (res.ok) {
			goto('/groups');
		}
	};

	const getGroupToEdit = async () => {
		//TODO: detail is outdated
		const { res, json } = await fetchRequest('GET', `group/${groupToEdit}/detail`);
		name = json.name;
		description = json.description;
		useInvite = !json.direct_join;
		publicGroup = json.public;
		if (image) image = `${env.PUBLIC_API}${json.image}`;
		if (coverImage) coverImage = `${env.PUBLIC_API}${json.cover_image}`;
	};

	onMount(() => {
		if (groupToEdit !== null) {
			getGroupToEdit();
		}
	});
</script>

<svelte:head>
	<title>Creating a Group</title>
</svelte:head>

<Layout centered>
	<Loader bind:loading>
		<form
			on:submit|preventDefault={createGroup}
			class="dark:text-darkmodeText mt-6 mb-6 flex items-start justify-center gap-8 md:mt-8 w-[1500px]"
		>
			<div class="bg-white dark:bg-darkobject p-6 shadow-xl flex flex-col gap-6 md:w-2/5">
				<h1 class="text-2xl">{$_(groupToEdit ? 'Update' : 'Create a Group')}</h1>
				<TextInput label="Title" bind:value={name} required />
				<TextArea label="Description" bind:value={description} />
				<ImageUpload icon={faUser} isProfile bind:imageString={image} label="Upload Image" />
				<ImageUpload icon={faFileImage} bind:imageString={coverImage} label="Upload Banner" />

				{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
					<RadioButtons bind:Yes={useInvite} label={'Invitation Required?'} />
					<RadioButtons bind:Yes={publicGroup} label={'Public?'} />
					<RadioButtons bind:Yes={hiddenGroup} label={'Hide proposal creator?'} />
				{/if}

				<StatusMessage bind:status />

				<Button type="submit" disabled={loading}
					><div class="flex justify-center gap-3 items-center">
						<Fa icon={faPaperPlane} />{$_(groupToEdit ? 'Update' : 'Create Group')}
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
					<Button buttonStyle="warning" action={() => (DeleteGroupModalShow = true)}
						>{$_('Delete Group')}</Button
					>
				{/if}
			</div>
		</form>
	</Loader>
</Layout>

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import type { Tag as TagType } from '$lib/Group/interface';
	import { _ } from 'svelte-i18n';
	import Loader from '$lib/Generic/Loader.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { getTags } from './functions';
	import Tag from './Tag.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import Fa from 'svelte-fa';
	import { faTrash } from '@fortawesome/free-solid-svg-icons';
	import Toggle from '$lib/Generic/Toggle.svelte';

	let tags: TagType[] = [],
		tagToAdd = '',
		selectedTag: TagType = { active: false, id: 0, name: '', imac: 0 },
		loading = false,
		areYouSureModal = false,
		poppup: poppup;

	onMount(async () => {
		await getTagsLocal();
	});

	const getTagsLocal = async () => {
		loading = true;
		tags = await getTags($page.params.groupId);
		if (!tags) poppup = { message: 'Could not get poppups', success: false };
		loading = false;
	};

	const addTag = async () => {
		loading = true;
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/tag/create`, {
			name: tagToAdd
		});
		if (res.ok) {
			getTagsLocal();
			tagToAdd = '';
		} else loading = false;
	};

	const removeTag = async (tag: TagType) => {
		console.log(tag, 'TAGG');
		loading = true;
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/tag/delete`, {
			tag: tag.id
		});
		//TODO: Just update DOM instead of re-getting tags
		if (res.ok) {
			getTagsLocal();
			areYouSureModal = false;
		} else loading = false;
	};

	const editTag = async (tag: TagType) => {
		loading = true;
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/tag/update`, {
			tag: tag.id,
			active: !tag.active
		});
		if (res.ok) getTagsLocal();
		else loading = false;
	};
</script>

<!-- TODO: Nicer design -->
<!-- <div class="bg-white rounded shadow p-6 dark:bg-darkobject"> -->
<Loader bind:loading>
	<form on:submit|preventDefault={addTag} class="pb-4 flex gap-2">
		<TextInput label="Add tag" bind:value={tagToAdd} required Class="flex-1 p-1" />
		<Button
			disabled={loading}
			type="submit"
			Class="w-1/5 mt-[1.65rem] h-8 flex items-center justify-center"
			buttonStyle="primary-light"
			label="Add"
		/>
	</form>
	<div class="flex flex-col justify-between gap-2 py-2">
		{#each tags as tag}
			<!-- <div class="md:w-1/2 lg:w-1/3 xl:w-1/4 p-3"> -->
			<div class="flex justify-between items-center">
				<p>{tag?.name}</p>
				<!-- <Tag {tag} Class={tag.active ? '' : 'bg-blue-200'} /> -->
				<div class="flex gap-2 items-center ml-auto">
					<!-- <div class="w-6 h-3"></div> -->
					<Toggle checked={tag.active} onInput={() => editTag(tag)} />
					<!-- </div> -->
					<!-- <Button 
								disabled={loading} 
								buttonStyle="primary-light"
								action={() => editTag(tag)}
								label={tag.active ? $_('Disable') : $_('Activate')}
							/> -->
					<button
						class="text-red-500 p-2 pl-4 text-lg cursor-pointer"
						disabled={loading}
						on:click={() => {
							areYouSureModal = true;
							selectedTag = tag;
						}}
						><Fa icon={faTrash} />
					</button>

					<!-- <Button
								disabled={loading}
								buttonStyle="warning-light"
								action={() => {
									areYouSureModal = true;
									selectedTag = tag;
								}}>{$_('Delete')}</Button
							> -->
				</div>
			</div>
			<!-- </div> -->
		{/each}
	</div>
</Loader>
<!-- </div> -->

<Modal bind:open={areYouSureModal}>
	<div slot="header">{$_('Are you sure?')}</div>
	<div slot="body">
		<span>{$_('Removing a tag removes all polls with that tag!')}</span>
		<br />
		<span>{$_('You are removing')}: {selectedTag?.name}</span>
	</div>
	<div slot="footer" class="flex gap-2">
		<Button action={() => removeTag(selectedTag)} Class="bg-red-500 w-1/2">{$_('Yes')}</Button>
		<Button action={() => (areYouSureModal = false)} Class="bg-gray-600 w-1/2">{$_('No')}</Button>
	</div>
</Modal>

<Poppup bind:poppup />

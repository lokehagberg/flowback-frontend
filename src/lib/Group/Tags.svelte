<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import Tag from './Tag.svelte';
	import type { Tag as TagType } from '$lib/Group/interface';
	import { _ } from 'svelte-i18n';
	import Loader from '$lib/Generic/Loader.svelte';
	import Modal from '$lib/Generic/Modal.svelte';

	let tags: TagType[] = [];
	let tagToAdd = '';
	let loading = false;
	let areYouSureModal = false;

	onMount(async () => {
		getTags();
	});

	const getTags = async () => {
		loading = true;
		console.log('here');
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/tags?limit=100`);
		tags = json.results.sort((tag1: TagType, tag2: TagType) =>
			tag1.tag_name.localeCompare(tag2.tag_name)
		);
		loading = false;
	};

	const addTag = async () => {
		loading = true;
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/tag/create`, {
			tag_name: tagToAdd
		});
		if (res.ok) {
			getTags();
			tagToAdd = '';
		} else loading = false;
	};

	const removeTag = async (tag: TagType) => {
		loading = true;
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/tag/delete`, {
			tag: tag.id
		});
		//TODO: Just update DOM instead of re-getting tags
		if (res.ok) getTags();
		else loading = false;
	};

	const editTag = async (tag: TagType) => {
		loading = true;
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/tag/update`, {
			tag: tag.id,
			active: !tag.active
		});
		if (res.ok) getTags();
		else loading = false;
	};
</script>

<div class="bg-white rounded shadow p-6">
	<Loader bind:loading>
		<form on:submit|preventDefault={addTag} class="p-3">
			<TextInput label="Add tag" bind:value={tagToAdd} />
			<Button disabled={loading} type="submit" Class="mt-2" label="Add tag" />
		</form>
		<div class="flex flex-wrap mt-2">
			{#each tags as tag}
				<div class="w-full md:w-1/2 lg:w-1/3 xl:w-1/4 p-3">
					<Tag tag={tag.tag_name} Class={tag.active ? '' : 'bg-blue-200'} />
					<div class="mt-2 w-full flex flex-col gap-2">
						<Button disabled={loading} Class="bg-purple-500" action={() => editTag(tag)}
							>{tag.active ? $_('Disable') : $_('Activate')}</Button
						>
						<Button
							disabled={loading}
							Class="bg-rose-500"
							action={() => (areYouSureModal = true)}>{$_('Delete')}</Button
						>
						<Modal bind:open={areYouSureModal}>
							<div slot="header">{$_('Are you sure?')}</div>
							<div slot="body">{$_('Removing a tagg removes all polls with that tag!')}</div>
							<div slot="footer">
								<Button
									action={() => {
										removeTag(tag);
										areYouSureModal = false;
									}}
									Class="bg-red-500">{$_('Yes')}</Button
								>
								<Button action={() => (areYouSureModal = false)} Class="bg-gray-600 w-1/2"
									>{$_('No')}</Button
								>
							</div>
						</Modal>
					</div>
				</div>
			{/each}
		</div>
	</Loader>
</div>

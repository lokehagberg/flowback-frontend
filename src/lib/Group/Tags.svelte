<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import Tag from './Tag.svelte';
	import type {Tag as TagType} from '$lib/Group/interface'

	let tags: TagType[] = [];
	let tagToAdd = '';

	onMount(async () => {
		getTags();
	});

	const getTags = async () => {
		console.log("here")
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/tags?limit=100`);
		tags = json.results.sort((tag1:TagType, tag2:TagType) => tag1.tag_name.localeCompare(tag2.tag_name));
	};

	const addTag = async () => {
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/tag/create`, {
			tag_name: tagToAdd
		});
		if (res.ok) {
			getTags();
			tagToAdd = ""
		}
	};

	const removeTag = async (tag: TagType) => {
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/tag/delete`, {
			tag: tag.id
		});
		if (res.ok) getTags();
	};

	const editTag = async (tag: TagType) => {
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/tag/update`, {
			tag: tag.id,
			active: !tag.active
		});
		if (res.ok) getTags();
	};
</script>

<div class="bg-white rounded shadow p-6">
	<form on:submit|preventDefault={addTag} class="p-3">
		<TextInput label="Add tag" bind:value={tagToAdd} />
		<ButtonPrimary type="submit" Class="mt-2" />
	</form>
	<div class="flex flex-wrap mt-2">
		{#each tags as tag}
			<div class="w-full md:w-1/2 lg:w-1/3 xl:w-1/4 p-3">
				<Tag tag={tag.tag_name} Class={tag.active ? '' : 'bg-blue-200'} />
				<div class="mt-2 w-full flex flex-col gap-2">
					<ButtonPrimary Class="bg-rose-500" action={() => removeTag(tag)}
						>Delete</ButtonPrimary
					>
					<ButtonPrimary Class="bg-purple-500" action={() => editTag(tag)}
						>{tag.active ? 'Disable' : 'Activate'}</ButtonPrimary
					>
				</div>
			</div>
		{/each}
	</div>
</div>

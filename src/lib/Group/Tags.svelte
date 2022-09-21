<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import Tag from './Tag.svelte';

	interface Tag {
		id: number;
		tag_name: string;
		active: boolean;
	}

	let tags: Tag[] = [];
	let tagToAdd = '';

	onMount(async () => {
		getTags();
	});

	const getTags = async () => {
		console.log("here")
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/tags?limit=100`);
		tags = json.results;
	};

	const addTag = async () => {
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/tag/create`, {
			tag_name: tagToAdd
		});
		if (res.ok) getTags();
	};

	const removeTag = async (tag: Tag) => {
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/tag/delete`, {
			tag: tag.id
		});
		if (res.ok) getTags();
	};

	const editTag = async (tag: Tag) => {
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
		<ButtonPrimary type="submit" className="mt-2" />
	</form>
	<div class="flex flex-wrap mt-2">
		{#each tags as tag}
			<div class="w-full md:w-1/2 lg:w-1/3 xl:w-1/4 p-3">
				<Tag tag={tag.tag_name} className={tag.active ? '' : 'bg-blue-200'} />
				<div class="mt-2 w-full">
					<ButtonPrimary className="bg-rose-500 w-1/2" action={() => removeTag(tag)}
						>Delete</ButtonPrimary
					>
					<ButtonPrimary className="bg-purple-500 w-1/2" action={() => editTag(tag)}
						>{tag.active ? 'Disable' : 'Activate'}</ButtonPrimary
					>
				</div>
			</div>
		{/each}
	</div>
</div>

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import Tag from './Tag.svelte';

	let tags: any[] = [];
	let tagToAdd = '';

	onMount(async () => {
		const res = await fetchRequest('GET', `group/${$page.params.groupId}/tags?limit=100`);
		const json = await res.json();
		tags = json.results;
		console.log(json.results);

		editTag({ id: 1 });
	});

	const addTag = () => {
		fetchRequest('POST', `group/${$page.params.groupId}/tag/create`, { tag_name: tagToAdd });
	};

	const removeTag = (tag: any) => {
		fetchRequest('POST', `group/${$page.params.groupId}/tag/delete`, { tag: tag.id });
	};

	const editTag = (tag: any) => {
		fetchRequest('POST', `group/${$page.params.groupId}/tag/update`, { id: tag.id, active: false });
	};
</script>

<div class="bg-white rounded shadow p-6">
	<form on:submit|preventDefault={addTag}>
		<TextInput label="add tag" bind:value={tagToAdd} />
		<ButtonPrimary type="submit" />
	</form>

	{#each tags as tag}
		<Tag tag={tag.tag_name} />
		<ButtonPrimary action={() => removeTag(tag)}>Delete</ButtonPrimary>
	{/each}
</div>

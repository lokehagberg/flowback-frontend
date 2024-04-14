<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Select from '$lib/Generic/Select.svelte';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import Tag from '$lib/Group/Tag.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';

	let tags: Tag[] = [],
		selectedTag: number,
		show = false,
		message = '';

	const getTags = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/tags?limit=1000&active=true`
		);
		if (!res.ok) {
			show = true;
			message = 'Could not get tags';
			return;
		}

		tags = json.results;
	};

	const vote = async () => {
		console.log(selectedTag);
		const { json, res } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/area/update`,
			{
				tag: selectedTag,
				vote: true
			}
		);

		show = true;
		if (!res.ok) message = 'Could not vote on tag';
		else message = 'Successfully voted for area';
	};

	const changeSelect = (tag: Tag) => {
		selectedTag = tag.id;
		vote();
	};

	onMount(() => {
		getTags();
	});
</script>

<div class={`grid grid-cols-3 grid-rows-${Math.ceil(tags.length / 3)}`}>
	{#each tags as tag}
		<Button
			buttonStyle={selectedTag === tag.id ? 'primary' : 'secondary'}
			action={() => changeSelect(tag)}>{tag.name}</Button
		>
	{/each}
</div>

<SuccessPoppup bind:show bind:message />

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import Tag from '$lib/Group/Tag.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import { elipsis } from '$lib/Generic/GenericFunctions';

	let tags: Tag[] = [],
		selectedTag: number | null = null,
		poppup: poppup;

	const getTags = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/tags?limit=1000&active=true`
		);
		if (!res.ok) {
			poppup = { message: 'Could not get tags', success: false };
			return;
		}

		tags = json.results;
	};

	const vote = async (tagId: number) => {
		const { json, res } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/area/update`,
			{
				tag: tagId,
				vote: true
			}
		);

		if (!res.ok) {
			poppup = { message: 'Could not vote on tag', success: false };
			return;
		}

		if (tagId === selectedTag) selectedTag = null;
		else selectedTag = tagId;

		poppup = { message: 'Successfully voted for area', success: true };
	};

	const getAreaVote = async () => {
		const { json, res } = await fetchRequest('GET', `group/poll/${$page.params.pollId}/area/list`);

		if (!res.ok) return;

		let selectedTagName = json.results.find((tag: Tag) => tag.user_vote === true)?.tags[0].tag_name;

		if (selectedTagName) {
			selectedTag = tags.find((tag) => tag.name === selectedTagName)?.id;
		}
	};

	onMount(async () => {
		await getTags();
		getAreaVote();
	});
</script>

<!-- <RadioButtons2
		name="vote"
		labels={tags.map((tag) => tag.name)}
		values={tags.map((tag) => tag.id)}
		ClassInner="block"
		bind:value={selectedTag}
	/>  -->
<div class={`grid-rows-${Math.ceil(tags.length / 3)}`}>
	{#each tags as tag}
		{#if tag.active}
			<div>
				<input type="radio" name="area" on:change={() => vote(tag.id)} />
				{elipsis(tag.name, 40)}
			</div>
		{/if}
	{/each}
</div>

<Poppup bind:poppup />

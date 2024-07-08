<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import Tag from '$lib/Group/Tag.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import { toPercentage } from 'chart.js/helpers';

	let tags: Tag[] = [],
		selectedTag: number,
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

	const vote = async () => {
		const { json, res } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/area/update`,
			{
				tag: selectedTag,
				vote: true
			}
		);

		if (!res.ok) {
			poppup = { message: 'Could not vote on tag', success: false };
			return;
		}

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

	const changeSelect = (tag: Tag) => {
		selectedTag = tag.id;
		vote();
	};

	onMount(async () => {
		await getTags();
		getAreaVote();
	});
</script>

<div class={`grid gap-2 grid-cols-3 grid-rows-${Math.ceil(tags.length / 3)}`}>
	{#each tags as tag}
		{#if tag.active}
			<Button
				buttonStyle={selectedTag === tag.id ? 'primary' : 'secondary'}
				action={() => changeSelect(tag)}
			>
				{tag.name}
			</Button>
		{/if}
	{/each}
</div>

<Poppup bind:poppup />

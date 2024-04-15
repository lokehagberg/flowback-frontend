<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import Tag from '$lib/Group/Tag.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';

	let tags: Tag[] = [],
		selectedTag: number,
		poppup = { show: false, message: '', success: true };

	const getTags = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/tags?limit=1000&active=true`
		);
		if (!res.ok) {
			poppup.show = true;
			poppup.message = 'Could not get tags';
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

		poppup.show = true;
		if (!res.ok) {
			poppup.message = 'Could not vote on tag';
			poppup.success = false;
			return;
		}
		poppup.message = 'Successfully voted for area';
		poppup.success = true;
	};

	const getAreaVote = async () => {
		const { json, res } = await fetchRequest('GET', `group/poll/${$page.params.pollId}/area/list`);

		if (res.ok) {
			const votedFor = json.results[0].tag_name;
			const votedTag = tags.find((tag) => tag.tag_name === votedFor);
			if (votedTag) selectedTag = votedTag.id;
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
		<Button
			buttonStyle={selectedTag === tag.id ? 'primary' : 'secondary'}
			action={() => changeSelect(tag)}>{tag.name}</Button
		>
	{/each}
</div>

<Poppup bind:poppup />

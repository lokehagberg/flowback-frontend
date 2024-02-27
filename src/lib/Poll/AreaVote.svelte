<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Select from '$lib/Generic/Select.svelte';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import Tag from '$lib/Group/Tag.svelte';
	import Button from '$lib/Generic/Button.svelte';

	let tags: Tag[] = [],
		selectedTag: Tag;

	const getTags = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/tags?limit=1000`
		);
		if (!res.ok) return;
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
		if (!res.ok) return;
	};

	onMount(() => {
		getTags();
	});

	$: console.log(selectedTag);
</script>

<div>
	<Select labels={tags.map((tag) => tag.name)} bind:value={selectedTag} />
	<Button action={vote}>Vote</Button>
</div>

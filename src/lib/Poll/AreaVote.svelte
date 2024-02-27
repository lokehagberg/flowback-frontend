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
			`group/${$page.params.groupId}/tags?limit=1000`
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
		if (!res.ok) {
			show = true;
			message = 'Could not vote on tag';
			return;
		}
	};

	onMount(() => {
		getTags();
	});

	$: console.log(selectedTag);
</script>

<div>
	<Select
		labels={tags.map((tag) => tag.name)}
		values={tags.map((tag) => tag.id)}
		bind:value={selectedTag}
	/>
	<Button action={vote}>Vote</Button>
</div>

<SuccessPoppup bind:show bind:message />

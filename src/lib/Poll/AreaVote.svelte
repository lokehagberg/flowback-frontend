<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import Tag from '$lib/Group/Tag.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import { elipsis } from '$lib/Generic/GenericFunctions';
	import { _ } from 'svelte-i18n';

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

	// const vote = async (tagId: number) => {
	// 	const { json, res } = await fetchRequest(
	// 		'POST',
	// 		`group/poll/${$page.params.pollId}/area/update`,
	// 		{
	// 			tag: tagId,
	// 			vote: true
	// 		}
	// 	);

	// 	if (!res.ok) {
	// 		poppup = { message: 'Could not vote on tag', success: false };
	// 		return;
	// 	}

	// 	if (tagId === selectedTag) selectedTag = null;
	// 	else selectedTag = tagId;

	// 	poppup = { message: 'Successfully voted for area', success: true };
	// };

	const submitVote = async () => {
		if (selectedTag === null) {
			poppup = { message: 'Please select a tag before submitting.', success: false };
			return;
		}

		const { res } = await fetchRequest(
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

	const cancelVote = () => {
		selectedTag = null;
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

<div class="m-4 flex flex-col h-[800px]">
	<h2 class="text-xl font-semibold mb-4 text-primary dark:text-secondary">
		{$_('Areas')} ({tags.length})
	</h2>

	<div class="flex-grow flex flex-col gap-3 overflow-auto">
		{#each tags as tag}
			{#if tag.active}
				<div class="flex items-center space-x-3">
					<input 
						type="radio"
						name="area"
						on:change={() => selectedTag = tag.id}
						checked={selectedTag === tag.id}
						class="cursor-pointer" 
					/>
					<span>{elipsis(tag.name, 40)}</span>
				</div>
			{/if}
		{/each}
	</div>

	<div class="mt-auto pt-4 flex gap-2">
		<Button
			type="button"
			buttonStyle="primary-light"
			Class="flex-1"
			onClick={submitVote}
		>
			{$_('Submit')}
		</Button>
		<Button
			type="button"
			buttonStyle="warning-light"
			Class="flex-1"
			onClick={cancelVote}
		>
			{$_('Cancel')}
		</Button>
	</div>
</div>

<Poppup bind:poppup />

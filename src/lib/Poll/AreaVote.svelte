<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import Tag from '$lib/Group/Tag.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import { elipsis } from '$lib/Generic/GenericFunctions';
	import { _ } from 'svelte-i18n';
	import Question from '$lib/Generic/Question.svelte';
	import { idfy } from '$lib/Generic/GenericFunctions2';

	let tags: Tag[] = [],
		selectedTag: number | null = null;

	const getTags = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/tags?limit=1000&active=true`
		);
		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Could not get tags', success: false });
			return;
		}

		tags = json?.results;
	};

	const submitVote = async () => {
		if (selectedTag === null) {
			ErrorHandlerStore.set({
				message: 'Please select a tag before submitting.',
				success: false
			});
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
			ErrorHandlerStore.set({
				message: 'Could not vote on tag',
				success: false
			});
			return;
		}

		ErrorHandlerStore.set({
			message: 'Successfully voted for area',
			success: true
		});
	};

	const getAreaVote = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/area/list`
		);

		if (!res.ok) return;

		let selectedTagName = json?.results.find(
			(tag: Tag) => tag.user_vote === true
		)?.tags[0].tag_name;

		if (selectedTagName) {
			selectedTag = tags.find((tag) => tag.name === selectedTagName)?.id;
		}
	};

	const cancelVote = () => {
		selectedTag = null;
		ErrorHandlerStore.set({ message: 'Vote cancelled', success: true });
	};

	onMount(async () => {
		await getTags();
		getAreaVote();
	});
</script>

<!-- <div class="flex flex-col h-[40vh] md:h-[50vh] lg:h-[60vh] xl:h-[70vh] max-h-[350px]"> -->
<div class="flex flex-col h-full">
	<h2 class="text-xl font-semibold mb-4 text-primary dark:text-secondary">
		{$_('Areas')} ({tags.length})
	</h2>

	<div class="flex-grow flex flex-col gap-3 overflow-auto">
		{#each tags as tag}
			{#if tag.active}
				<div
					id={`tag-${idfy(tag.name)}`}
					class="flex items-center space-x-3 flex-wrap"
				>
					<input
						type="radio"
						name="area"
						on:change={() => (selectedTag = tag.id)}
						checked={selectedTag === tag.id}
						class="cursor-pointer"
					/>
					<span class="whitespace-nowrap flex-1">
						{elipsis(tag.name, 40)}
					</span>
					{#if tag.description}
						<Question message={tag.description} />
					{/if}
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
			disabled={selectedTag === null}
		>
			{$_('Submit')}
		</Button>
		<Button
			type="button"
			buttonStyle="warning-light"
			Class="flex-1 disabled:!text-gray-300"
			onClick={cancelVote}
			disabled={selectedTag === null}
		>
			{$_('Cancel')}
		</Button>
	</div>
</div>

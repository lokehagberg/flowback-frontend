<script lang="ts">
	import ProposalSubmition from './ProposalSubmition.svelte';
	import ProposalsRanked from '$lib/Poll/ProposalsRanked.svelte';
	import Timeline from '$lib/Poll/Timeline.svelte';
	import Comments from '$lib/Poll/Comments.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Tag from '$lib/Group/Tag.svelte';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { poll } from '$lib/Poll/interface';

	let poll: poll;

	onMount(async () => {
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/poll/list`, {
			id: $page.params.pollId
		});

		poll = json.results[0];
	});
</script>

{#if poll}
	<Layout>
		<!-- <TestDraggable /> -->
		<div class="p-10 m-10 bg-white rounded shadow pt-6">
			<div class="flex gap-6">
				<h1 class="text-left text-3xl mt-auto mb-auto">{poll.title}</h1>
				<!-- TODO: Icons for type of poll and time -->
				<!-- <div class="mt-auto mb-auto"><HeaderIcon /></div>
				<div class="mt-auto mb-auto"><HeaderIcon /></div> -->
			</div>
			{poll.description}
			<!-- <div class="italic mt-4">Group name</div> -->
			<Tag Class="w-32 mb-4 mt-4" tag={poll.tag_name} />
			<ProposalsRanked />
			<ProposalSubmition />
			<Timeline dates={[new Date(poll.start_date), new Date(poll.end_date)]} />
			<Comments />
		</div>
	</Layout>
{/if}

<script lang="ts">
	import ProposalSubmition from '../../../../lib/Poll/ProposalSubmition.svelte';
	import ProposalsRanked from '$lib/Poll/ProposalsRanked.svelte';
	import Timeline from '$lib/Poll/Timeline.svelte';
	import Comments from '$lib/Poll/Comments.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Tag from '$lib/Group/Tag.svelte';
	import { onMount } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { poll, proposal, votings } from '$lib/Poll/interface';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import Tab from '$lib/Generic/Tab.svelte';
	import { mode } from '$lib/configuration';

	let poll: poll;
	let votings: votings[];
	let selectedPage: 'You' | 'Delegate' = 'You';
	let abstained: proposal[];

	$: console.log(abstained, 'ABS');

	onMount(async () => {
		getPollData();
	});

	const getPollData = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/list?limit=100&id=${$page.params.pollId}`
		);

		poll = json.results[0];
	};

	const deletePoll = () => {
		fetchRequest('POST', `group/${$page.params.groupId}/poll/${$page.params.pollId}/delete`);
	};
</script>

{#if poll}
	<Layout centering={true}>
		<!-- <TestDraggable /> -->
		<div class="p-10 m-10 bg-white rounded shadow pt-6 flex flex-col gap-8 xl:w-2/3">
			<h1 class="text-left text-5xl p-4 mt-auto mb-auto">{poll.title}</h1>
			<div class="border border-gray-200 rounded p-4">
				<div class="flex gap-6">
					<!-- TODO: Icons for type of poll and time -->
					<!-- <div class="mt-auto mb-auto"><HeaderIcon /></div>
				<div class="mt-auto mb-auto"><HeaderIcon /></div> -->
				</div>
				{poll.description}
				<Tag Class="w-32 mb-4" tag={poll.tag_name} />
			</div>
			<!-- <div class="italic mt-4">Group name</div> -->
			<Tab tabs={['You', 'Delegate']} bind:selectedPage />
			<ProposalsRanked bind:votings bind:selectedPage bind:abstained tag={poll.tag} />
			<ProposalSubmition bind:abstained />
			<Timeline dates={[new Date(poll.start_date), new Date(poll.end_date)]} />
			{#if mode === 'Dev'}
				<Comments />
			{/if}
			<ButtonPrimary action={deletePoll} Class="bg-red-500 mt-6">Delete Poll</ButtonPrimary>
		</div>
	</Layout>
{/if}

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
	import { _ } from 'svelte-i18n';
	import Modal from '$lib/Generic/Modal.svelte';
	import Results from '$lib/Poll/Results.svelte';
	import { DateInput } from 'date-picker-svelte';
	import ScheduledSubmission from '$lib/Poll/ScheduledSubmission.svelte';

	let poll: poll;
	let votings: votings[];
	let selectedPage: 'You' | 'Delegate' = 'You';
	let abstained: proposal[];
	let DeletePollModalShow = false;
	let pollType = 1;

	$: console.log(abstained, 'ABS');

	onMount(async () => {
		getPollData();
	});

	const getPollData = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/list?id=${$page.params.pollId}`
		);

		poll = json.results[0];
		pollType = json.results[0].poll_type
	};

	const deletePoll = async () => {
		const { res } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/delete`
		);
		if (res.ok) window.location.href = `/groups/${$page.params.groupId}`;
	};
</script>

{#if poll}
	<Layout centering={true}>
		<div
			class="p-10 m-10 bg-white rounded shadow pt-6 flex flex-col gap-8 w-full md:w-3/4 lg:w-2/3 lg:max-w-[1000px]"
		>
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
			{#if !poll.finished}
				<Tab tabs={['You', 'Delegate']} bind:selectedPage />
				<ProposalsRanked bind:votings bind:selectedPage bind:abstained tag={poll.tag} />

				{#if pollType === 1}
					<!-- Ranked Poll -->
					<ProposalSubmition bind:abstained />
				{:else if pollType === 3}
					<!-- Scheduled Poll -->
					<ScheduledSubmission bind:abstained />
				{/if}
			{:else}
				<Results />
			{/if}
			<Timeline dates={[new Date(poll.start_date), new Date(poll.end_date)]} />
			{#if import.meta.env.VITE_MODE === 'DEV'}
				<Comments />
			{/if}
			<Modal bind:open={DeletePollModalShow}>
				<div slot="header">{$_('Deleting Poll')}</div>
				<div slot="body">{$_('Are you sure you want to delete this poll?')}</div>
				<div slot="footer">
					<div class="flex justify-center gap-16">
						<ButtonPrimary action={deletePoll} Class="bg-red-500">{$_('Yes')}</ButtonPrimary
						><ButtonPrimary action={() => (DeletePollModalShow = false)} Class="bg-gray-400 w-1/2"
							>{$_('Cancel')}</ButtonPrimary
						>
					</div>
				</div>
			</Modal>
			<ButtonPrimary action={() => (DeletePollModalShow = true)} Class="bg-red-500 mt-6"
				>{$_('Delete poll')}</ButtonPrimary
			>
		</div>
	</Layout>
{/if}

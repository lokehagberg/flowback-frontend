<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import Statistics from './Statistics.svelte';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faStar } from '@fortawesome/free-solid-svg-icons';
	import NewDescription from './NewDescription.svelte';
	import type { poll, proposal } from './interface';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';

	//4 for score voting, 3 for date
	export let pollType = 1,
		proposals: any[] = [],
		poll: poll,
		getPollData = () => {},
		selectedProposal: proposal | null = null;

	let votes: number[] = [],
		labels: string[] = [],
		noVotes = false;

	const getProposals = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposals?limit=1000&order_by=score_desc`
		);

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Failed to get proposals', success: false });
			return;
		}

		if (pollType === 4) proposals = json?.results;
		else if (pollType === 3)
			//Only one proposal wins in date poll
			proposals = [
				{
					id: json?.results[0].id,
					title: formatDate(json?.results[0].start_date),
					description: formatDate(json?.results[0].end_date)
				}
			];

		votes = proposals.map((proposal) => proposal.score) ?? [];
		labels = proposals.map((proposal) => proposal.title) ?? [];
		selectedProposal = proposals[0];
	};

	const formatDateTime = (dateString: string) => {
		const date = new Date(dateString);

		return {
			date: new Intl.DateTimeFormat('sv-SE', {
				weekday: 'long',
				day: '2-digit',
				month: 'long',
				year: 'numeric'
			})
				.format(date)
				.replace(/\b\w/g, (char) => char.toUpperCase()),

			time: new Intl.DateTimeFormat('sv-SE', {
				hour: '2-digit',
				minute: '2-digit',
				hour12: false
			}).format(date)
		};
	};

	onMount(async () => {
		await getProposals();
		noVotes = checkIfNoVotes();
		let k = 0;

		if (poll?.status === 2) {
			let time = setInterval(() => {
				if (poll.status === -1 || poll.status === 1 || k === 15) clearInterval(time);
				getProposals();
				getPollData();
				k++;
			}, 1000);
		}
	});

	//Checks the edge-case where no one with voting rights voted or delegated
	const checkIfNoVotes = () => {
		let totalVotes = 0;
		proposals.forEach((proposal) => {
			totalVotes += proposal.score;
		});

		return totalVotes === 0;
	};
</script>

<div class="w-full flex flex-col">
	<span class="text-primary dark:text-secondary font-semibold text-xl text-center block py-2"
		>{$_('Results')}</span
	>

	{#if pollType === 4}
		<!-- Conditional is split up to let poll status 0 both display text and list of proposals -->
		{#if poll?.status === 2}
			{$_('Calculating results...')}
		{:else if noVotes}
			{$_('There is no winning proposal because every proposal got zero votes')}
		{:else if poll?.status === -1}
			{$_('Vote calculation failed')}
		{/if}

		{#if poll?.status === 1 || poll?.status === 0}
			<!-- If the winner has atleast one point, display statistics (otherwise it looks empty) -->
			{#if proposals[0]?.score > 0}
				<Statistics bind:votes bind:labels />
			{/if}
			{#each proposals as proposal, i}
				<div class="border-gray-300 border-b-2 mt-3 pb-1 overflow-auto max-w-full">
					<span
						class="text-primary dark:text-secondary font-semibold flex items-center gap-1 break-words"
						>{#if i === 0 && !noVotes}
							<Fa icon={faStar} color="orange" />
						{/if}
						{proposal.title}</span
					>
					<NewDescription description={proposal.description} limit={2} lengthLimit={100} />
					<span class="block text-right"
						><span class="text-primary dark:text-secondary font-semibold">{$_('Points')}:</span>
						{proposal.score || '0'}</span
					>
				</div>
			{/each}
		{/if}
	{:else if pollType === 3}
		<div class="flex flex-col items-center justify-center h-full gap-4 mt-10">
			{#if proposals.length > 0}
				<Fa icon={faStar} color="orange" class="text-5xl" />
				<div class="text-primary dark:text-secondary font-semibold text-lg text-center block">
					{$_('Results have also been added to Group Schedule')}!
				</div>

				{#if proposals?.length > 0}
					{#if proposals[0].title && proposals[0].description}
						<div class="mt-2 text-center">
							<span>{formatDateTime(proposals[0].title).date}</span>
							<div class="mt-1 text-md text-gray-500">
								{formatDateTime(proposals[0].title).time} - {formatDateTime(
									proposals[0].description
								).time}
							</div>
						</div>
					{/if}
				{/if}
			{:else}
				{$_('No date was selected')}
			{/if}
		</div>
	{/if}
</div>

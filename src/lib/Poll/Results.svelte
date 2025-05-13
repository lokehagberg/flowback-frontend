<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import Statistics from './Statistics.svelte';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faStar, faUserCheck } from '@fortawesome/free-solid-svg-icons';
	import NewDescription from './NewDescription.svelte';
	import type { poll as pollTypeInterface } from './interface';
	import type { DelegateRelation, DelegateVote, DelegationTag } from '../Group/Delegation/interfaces';

	let votes: number[] = [],
		labels: string[] = [],
		delegateVotes: DelegateVote[] = [],
		userDelegations: DelegateRelation[] = [];

	//4 for score voting, 3 for date
	export let pollType = 1,
		proposals: any[] = [],
		poll: pollTypeInterface;

	const getProposals = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposals?limit=1000&order_by=score_desc`
		);
		console.log('WHAAAATTT', json, pollType);

		if (pollType === 4) proposals = json.results;
		else if (pollType === 3)
			//Only one proposal wins in date poll
			proposals = [
				{
					id: json.results[0].id,
					title: formatDate(json.results[0].start_date),
					description: formatDate(json.results[0].end_date)
				}
			];

		votes = proposals.map((proposal) => proposal.score) || [];
		labels = proposals.map((proposal) => proposal.title) || [];
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

	const getUserDelegations = async () => {
		if (!poll?.group_id) return;
		
		const { res, json } = await fetchRequest('GET', `group/${poll.group_id}/delegate/relation`);
		if (!res.ok) return;
		
		userDelegations = json.results;
		
		if (poll.tag_id) {
			const delegationForTag = userDelegations.find((relation: DelegateRelation) => 
				relation.tags.some((tag: DelegationTag) => tag.id === poll.tag_id)
			);
			
			if (delegationForTag && delegationForTag.delegates.length) {
				// Get delegate votes
				await getDelegateVotes(delegationForTag.delegates.map((d) => d.id));
			}
		}
	};

	const getDelegateVotes = async (delegateIds: number[]) => {
		if (!delegateIds.length) return;
		
		const delegateIdsParam = delegateIds.join(',');
		const { res, json } = await fetchRequest(
			'GET', 
			`group/poll/${$page.params.pollId}/votes?delegate_ids=${delegateIdsParam}`
		);
		
		if (!res.ok) return;
		
		delegateVotes = json.results;
	};

	onMount(() => {
		getProposals();
		getUserDelegations();
	});
</script>

<div class="w-full">
	<span class="text-primary dark:text-secondary font-semibold text-xl text-center block py-2"
		>{$_('Results')}</span
	>

	{#if pollType === 4}
		<!-- If the winner has atleast one point, display statistics (otherwise it looks empty) -->
		{#if poll?.status === 2 || poll?.status === 0}
			{$_('Calculating results, try refreshing in a while.')}
		{:else if poll?.status === -1}
			{$_('Vote calculation failed')}
		{:else}
			{#if proposals[0]?.score > 0}
				<Statistics bind:votes bind:labels />
			{/if}
			
			{#if delegateVotes.length > 0}
				<div class="mt-4 mb-2 p-3 bg-blue-50 dark:bg-blue-900 rounded-md border border-blue-200 dark:border-blue-700">
					<div class="flex items-center gap-2 mb-2">
						<Fa icon={faUserCheck} class="text-blue-500 dark:text-blue-300" />
						<span class="font-medium">{$_('Your delegate votes')}</span>
					</div>
					{#each delegateVotes as vote}
						<div class="ml-6 mb-1 text-sm">
							<span class="font-medium">{vote.delegate_username || $_('Delegate')}:</span> 
							{#if vote.proposal_id}
								{$_('Voted for')} <span class="font-semibold">{vote.proposal_title || proposals.find(p => p.id === vote.proposal_id)?.title || vote.proposal_id}</span>
							{:else}
								{$_('Did not vote')}
							{/if}
						</div>
					{/each}
				</div>
			{/if}
			
			{#each proposals as proposal, i}
				<div class="border-gray-300 border-b-2 mt-3 pb-1">
					<span
						class="text-primary dark:text-secondary font-semibold flex items-center gap-1 break-words"
						>{#if i === 0} <Fa icon={faStar} color="orange" /> {/if}
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
			<Fa icon={faStar} color="orange" class="text-5xl" />
			<div class="text-primary dark:text-secondary font-semibold text-lg text-center block">
				{$_('Results have also been added to Group Schedule')}!
			</div>

			{#if proposals?.length > 0}
				{#if proposals[0].title && proposals[0].description}
					<div class="mt-2 text-center">
						<span>{formatDateTime(proposals[0].title).date}</span>
						<div class="mt-1 text-md text-gray-500">
							{formatDateTime(proposals[0].title).time} - {formatDateTime(proposals[0].description)
								.time}
						</div>
					</div>
				{/if}
			{/if}
		</div>
	{/if}
</div>

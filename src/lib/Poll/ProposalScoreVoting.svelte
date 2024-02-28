<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { proposal } from '$lib/Poll/interface';
	import Proposal from './Proposal.svelte';
	import ProposalNew from './ProposalNew.svelte';
	import { proposals as proposalsLimit } from '../Generic/APILimits.json';
	import { onMount } from 'svelte';

	export let proposals: proposal[] = [];

	const vote = () => {
		fetchRequest(`POST`, `group/poll/${$page.params.pollId}/proposal/vote/delegate/update`, {
			proposals: [5, 6, 7],
			scores: [1, 2, 3]
		});
	};

    const getProposals = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/proposals?limit=${proposalsLimit}`
		);

		proposals = json.results;
		
	
	};

    onMount(() => {
        getProposals()
    })
</script>

<div>
	{#each proposals as proposal}
		<ProposalNew {proposal} />
	{/each}

	<Button action={vote} />
</div>

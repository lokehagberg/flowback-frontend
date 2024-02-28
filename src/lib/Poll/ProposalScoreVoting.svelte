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

    let voting:{score: number, proposal:number}[] = proposals.map(proposal => ({score:0, proposal: proposal.id}))

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

    const changingVote = (e:Event, proposalId:number) => {
        //@ts-ignore
        let newScore = e?.target?.value
        const i = voting.findIndex(vote => vote.proposal === proposalId)
        voting[i].score = Number(newScore)
        voting = voting
    }

    $: console.log(voting, "VOOOT")

    onMount(() => {
        getProposals()
    })
</script>

<div>
	{#each proposals as proposal}
		<ProposalNew {proposal} onChange={(e) => changingVote(e, proposal.id)} />
	{/each}

	<Button action={vote} >Save Votings</Button>
</div>

<script lang="ts">
	import { fetchRequest } from "$lib/FetchRequest";
	import Proposal from "./Proposal.svelte";
    import {page} from '$app/stores'
	import type { proposal } from "$lib/typescriptexperiments";
	import { onMount } from "svelte";
	import { formatDate } from "$lib/Generic/DateFormatter";

    let proposals : proposal[] = []
    export let pollType = 1;

    const getProposals = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposals?limit=100`
		);
        console.log(json)

        if (pollType === 1)
		proposals = json.results;
        else if (pollType === 3)
        proposals = [{id:json.results[0].id, title: formatDate(json.results[0].start_date), description:formatDate(json.results[0].end_date)}]
	};

    onMount(() => {
        getProposals();
    })

</script>

<div class="border border-gray- p-4 rounded">
    {#each proposals as proposal}
    <div class="border p-4">
        <h1 class="text-xl">Start: {proposal.title}</h1>
        <div>Slut: {proposal.description}</div>
        <div class="text-xl font-bold">Poäng: {proposal.score || "0"}</div>
    </div>
    {/each}
    <!-- <Proposal /> -->
</div>
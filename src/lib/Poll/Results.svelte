<script lang="ts">
	import { fetchRequest } from "$lib/FetchRequest";
	import Proposal from "./Proposal.svelte";
    import {page} from '$app/stores'
	import type { proposal } from "$lib/typescriptexperiments";
	import { onMount } from "svelte";

    let proposals : proposal[] = []

    const getProposals = async () => {
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposals?limit=100`
		);
		proposals = json.results;
	};

    onMount(() => {
        getProposals();
    })

</script>

<div class="border border-gray- p-4 rounded">
    {#each proposals as proposal}
    <div class="border p-4">
        <h1 class="text-xl">{proposal.title}</h1>
        <div>{proposal.description}</div>
        <div class="text-xl font-bold">Score: {proposal.score || "0"}</div>
    </div>
    {/each}
    <!-- <Proposal /> -->
</div>
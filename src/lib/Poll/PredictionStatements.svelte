<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { proposal } from './interface';
	import { page } from '$app/stores';
	import type { PredictionStatement } from './PredictionMarket/interfaces';

	export let selectedProposal: proposal;

	let predictions: PredictionStatement[] = [];

	const getPredictionStatements = async (selectedProposal: proposal) => {
		// loading = true;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/poll/prediction/statement/list?poll_id=${$page.params.pollId}
            &proposals=${selectedProposal.id}`
		);
		// loading = false;
		predictions = json.results;
        console.log(predictions)
	};

	$: if (selectedProposal) getPredictionStatements(selectedProposal);
</script>

<div>
    {#each predictions as prediction}
        {prediction.description}
    {/each}

</div>
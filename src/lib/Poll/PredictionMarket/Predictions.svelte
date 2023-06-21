<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import json from './PredictionTest.json';
	import { page } from '$app/stores';
	import Loader from '$lib/Generic/Loader.svelte';
	import Prediction from './Prediction.svelte';

	let loading = false,
		predictions: any[] = [];

	const getDelegateHistory = async () => {
		loading = true;
		// const { res, json } = await fetchRequest('GET', `group/poll/pool/${history}/poll/votes`);
		loading = false;
		// const { res, json } = await fetchRequest(
		// 	'GET',
		// 	`group/${$page.params.groupId}/delegate/pools?id=${history}`
		// );
		// predictions = json.results[0];
        predictions = json
	};

	onMount(() => {
		getDelegateHistory();
	});
</script>

<Loader bind:loading>
	<h2>{$_("Prediction Market")}</h2>
	<ul>
		{#each predictions as prediction}
			<li><Prediction {prediction}/></li>
		{/each}
	</ul>
</Loader>

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Select from '$lib/Generic/Select.svelte';
	import type { Prediction } from './interfaces';

	export let prediction: Prediction, loading: boolean;

	const predictionBetCreate = async (score: number) => {
		loading = true;

		score = score / 20;
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${prediction.id}/prediction/create`,
			{
				score
			}
		);
		loading = false;
	};
	const predictionBetDelete = async () => {
		loading = true;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${prediction.id}/prediction/delete`,
		);
		
		loading = false;
	};
</script>

<div class="flex justify-between">
	<span> {prediction.description}</span>
	<Select
		options={['Not selected', '0', '20', '40', '60', '80', '100']}
		onInput={(e) => {
			//@ts-ignore
			const score = e?.target?.value

			if (score === "Not selected") predictionBetDelete();
			else predictionBetCreate(score);
		}}
	/>
</div>

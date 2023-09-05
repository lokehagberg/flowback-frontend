<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Select from '$lib/Generic/Select.svelte';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import type { PredictionStatement } from './interfaces';

	export let prediction: PredictionStatement, loading: boolean, score: null | number;

	let showPoppup = false;

	const predictionBetCreate = async () => {
		console.log(score, 'SCOOOORE');
		loading = true;

		if (!score) return;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${prediction.id}/prediction/create`,
			{
				score
			}
		);
		loading = false;

		if (!res.ok) showPoppup = true;
	};
	const predictionBetDelete = async () => {
		loading = true;

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${prediction.id}/prediction/delete`
		);

		if (!res.ok) showPoppup = true;
		loading = false;
	};
</script>

<div class="flex justify-between">
	<span> {prediction.description}</span>
	<Select
		labels={['Not selected', '0', '20', '40', '60', '80', '100']}
		values={[null, 0, 1, 2, 3, 4, 5]}
		onInput={async (e) => {
			//@ts-ignore
			const selectedScore = e?.target?.value;
			await predictionBetDelete();

			if (selectedScore !== 'Not selected') predictionBetCreate();
		}}
	/>
</div>

<SuccessPoppup bind:show={showPoppup} message={'Something went wrong'} />

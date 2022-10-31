<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { DateInput } from 'date-picker-svelte';
	import { page } from '$app/stores';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import type { proposal } from './interface';

	let start_date: Date, end_date: Date;

	const maxDatePickerYear = new Date((new Date().getFullYear() + 5).toString());

	export let abstained: proposal[];

	const addProposal = async () => {
		const { json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposal/create`,
			{
				start_date,
				end_date
			}
		);

		abstained.push({
			title: start_date.toString(),
			description: end_date.toString(),
			id: json
		});

		abstained = abstained;
	};
</script>

<form on:submit|preventDefault={addProposal}>
	<DateInput
		format="yyyy-MM-dd HH:mm"
		closeOnSelection
		bind:value={start_date}
		min={new Date()}
		max={maxDatePickerYear}
	/>

	<DateInput
		format="yyyy-MM-dd HH:mm"
		closeOnSelection
		bind:value={end_date}
		min={new Date()}
		max={maxDatePickerYear}
	/>

	<ButtonPrimary type="submit" label="Lägg till" />
</form>

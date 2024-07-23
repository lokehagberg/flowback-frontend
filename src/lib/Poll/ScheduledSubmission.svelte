<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { DateInput } from 'date-picker-svelte';
	import { page } from '$app/stores';
	import Button from '$lib/Generic/Button.svelte';
	import type { proposal } from './interface';
	import { formatDate } from './functions';
	import Loader from '$lib/Generic/Loader.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { maxDatePickerYear } from '$lib/Generic/DateFormatter';

	let start_date: Date | null, end_date: Date | null, loading = false, status:StatusMessageInfo;

	export let abstained: proposal[];

	const addProposal = async () => {
		loading = true
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/proposal/create`,
			{
				start_date,
				end_date
			}
		);
		loading = false
		status = statusMessageFormatter(res, json)
		
		if (res.ok && start_date !== null && end_date !== null){
			abstained.push({
				title: formatDate(start_date.toString()),
				description: formatDate(end_date.toString()),
				id: json
			});	
			abstained = abstained;
			start_date = null
			end_date = null
		}
	};
</script>

<!-- {#if } -->
<form on:submit|preventDefault={addProposal} class="rounded border-gray-200 dark:border-gray-500 border p-4 z-30">
	<Loader bind:loading>
		<div class="text-xl">Add date proposal</div>
		<div class="mt-4">Start Date</div>
		<DateInput
			format="yyyy-MM-dd HH:mm"
			closeOnSelection
			bind:value={start_date}
			min={new Date()}
			max={end_date || maxDatePickerYear}
		/>

		<div class="mt-4">End Date</div>
		<DateInput
			format="yyyy-MM-dd HH:mm"
			closeOnSelection
			bind:value={end_date}
			min={start_date || new Date()}
			max={maxDatePickerYear}
		/>

		<Button Class="mt-4" type="submit" label="Add" />
		<StatusMessage bind:status Class="mt-4" />
	</Loader>
</form>

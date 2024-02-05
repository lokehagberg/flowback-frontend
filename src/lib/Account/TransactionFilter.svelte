<script lang="ts">
	import { _ } from 'svelte-i18n';
	import type { Account, Filter } from './interface';
	import Select from '$lib/Generic/Select.svelte';
	import DateInput from 'date-picker-svelte/DateInput.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';

	export let filter: Filter, handleSearch: () => {}, accounts: Account[];
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true;

    $: filter && handleSearch()
</script>

<form
	class="bg-white dark:bg-darkobject dark:text-darkmodeText shadow rounded p-6 flex flex-col w-full gap-4"
	on:submit|preventDefault={() => {
		searched = true;
		// handleSearch();
	}}
>
	<div class="w-full flex items-end">
		<!-- <input type="number" bind:value={filter.account_id}> -->

		<Select
			labels={accounts.map((account) => `${account.account_name} ${account.account_number}`)}
			values={accounts.map((account) => account.id)}
			bind:value={filter.account_id}
			onInput={(e) => {
				//@ts-ignore
				const selectedScore = e?.target?.value;
				filter.account_id = Number(selectedScore);
				// handleSearch();
			}}
		/>

		<DateInput bind:value={filter.date_after} />
		<DateInput bind:value={filter.date_before} />

        <!-- {#if filter.description !== undefined} -->
        <input type="text" bind:value={filter.description} />
<!-- {/if} -->
	</div>
	<div />
</form>

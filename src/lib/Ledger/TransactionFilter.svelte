<script lang="ts">
	import { _ } from 'svelte-i18n';
	import type { Account, Filter } from './interface';
	import Select from '$lib/Generic/Select.svelte';
	import DateInput from 'date-picker-svelte/DateInput.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { onMount } from 'svelte';
	import MultiSelect from '$lib/Generic/MultiSelect.svelte';
	import CheckboxButtons from '$lib/Generic/CheckboxButtons.svelte';

	export let filter: Filter, handleSearch: () => {}, accounts: Account[];
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true,
		labels: { label: string; checked: boolean; id: number }[] = [];

	onMount(() => {
		labels = accounts?.map((account) => {
			return {
				label: `${account.account_name} ${account.account_number}`,
				checked: false,
				id: account.id
			};
		});
	});

	const changingCheckbox = (id: number) => {
		let changeChecbox = filter.account_ids.find((label) => label.id === id);
		if (!changeChecbox) return;

		changeChecbox.checked = !changeChecbox.checked;

		filter.account_ids = filter.account_ids;
	};

	$: filter && handleSearch();
</script>

<form
	class="bg-white dark:bg-darkobject dark:text-darkmodeText shadow rounded p-6 flex flex-col w-full gap-4"
	on:submit|preventDefault={() => {
		searched = true;
	}}
>
	<div class="w-full flex items-end">
		<CheckboxButtons onChange={changingCheckbox} label="" labels={filter.account_ids} />

		<DateInput bind:value={filter.date_after} />
		<DateInput bind:value={filter.date_before} />

		<input
			type="text"
			class="bg-gray-200 dark:bg-darkbackground outline outline-1 outline-gray-300"
			bind:value={filter.description}
		/>
	</div>
	<div />
</form>

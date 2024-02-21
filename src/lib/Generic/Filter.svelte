<script lang="ts">
	import { _ } from 'svelte-i18n';
	import Select from '$lib/Generic/Select.svelte';
	import DateInput from 'date-picker-svelte/DateInput.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { onMount } from 'svelte';
	import MultiSelect from '$lib/Generic/MultiSelect.svelte';
	import CheckboxButtons from '$lib/Generic/CheckboxButtons.svelte';

	export let filter: any, handleSearch = () => {}, iterables: any[];
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true;

	const handleTags = (e: any) => {
		if (e.target.value === 'null') filter.tag = null;
		else filter.assignee = e.target.value;
		handleSearch();
	};
</script>

<form
	class="bg-white dark:bg-darkobject dark:text-darkmodeText shadow rounded p-6 flex flex-col w-full gap-4"
	on:submit|preventDefault={() => {
		searched = true;
	}}
>
	<div class="w-full flex items-end">
		<select on:input={handleTags} class="dark:bg-darkobject">
			<option value={null}>{$_('All')}</option>
			{#each iterables as iterable}
				<option value={iterable.id}>{iterable.name}</option>
			{/each}
		</select>

		<!-- <DateInput bind:value={filter.date_after} />
		<DateInput bind:value={filter.date_before} />

		<input
			type="text"
			class="bg-gray-200 dark:bg-darkbackground outline outline-1 outline-gray-300"
			bind:value={filter.description}
		/> -->
	</div>
	<div />
</form>

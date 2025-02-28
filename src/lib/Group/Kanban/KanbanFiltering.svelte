<script lang="ts">
	import TextInput from '$lib/Generic/TextInput.svelte';
	import type { Filter } from './Kanban.ts';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faMagnifyingGlass } from '@fortawesome/free-solid-svg-icons/faMagnifyingGlass';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { Tag } from '$lib/Group/interface';
	import { homePolls as homePollsLimit } from '$lib/Generic/APILimits.json';
	import Select from '$lib/Generic/Select.svelte';
	import { elipsis } from '$lib/Generic/GenericFunctions';

	export let filter: Filter,
		Class = '',
		handleSearch = () => {};
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true;

	const resetFilter = () => {};

	onMount(() => {});

	$: if (filter) handleSearch();
</script>

<form
	class="bg-white dark:bg-darkobject dark:text-darkmodeText shadow rounded p-4 flex flex-col w-full gap-4 ${Class}"
	on:submit|preventDefault={() => {
		searched = true;
		handleSearch();
	}}
>
	<div class="w-full flex items-end">
		<TextInput
			Class="w-4/5"
			inputClass="placeholder-gray-600 pl-2 pr-6 text-gray-500 border-0 bg-gray-100 dark:bg-darkobject"
			placeholder={$_('Search tasks')}
			onInput={() => (searched = false)}
			label=''
			max={null}
			search={true}
			bind:value={filter.search}
		/>

		<Button
			Class={`w-8 h-8 ml-4 !p-1 flex justify-center items-center ${
				searched ? 'bg-blue-300' : 'bg-blue-600'
			}`}
			type="submit"
		>
			<Fa icon={faMagnifyingGlass} />
		</Button>
	</div>
</form>

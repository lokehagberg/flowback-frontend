<script lang="ts">
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { _ } from 'svelte-i18n';
	import Button from '$lib/Generic/Button.svelte';
	import type { GroupFilter } from './interface';
	import Select from '$lib/Generic/Select.svelte';

	export let filter: GroupFilter;
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true;
	let searchQuery = filter.search || '';

	const handleChangeMember = (e: any) => {
		filter.joined = e.target.value;
	};

	const handleSearch = () => {
		filter.search = searchQuery;
		searched = true;
	};

	const handleSearchInput = () => {
		searched = false;
		setTimeout(() => {
			filter.search = searchQuery;
		}, 300);
	};

	const resetFilter = () => {
		filter.joined = 'all';
		filter.search = '';
		searchQuery = '';
		searched = true;
	};

	$: if (searchQuery === '') {
		filter.search = searchQuery;
		searched = false;
	}
</script>

<form
	class="bg-white dark:bg-darkobject dark:text-darkmodeText shadow rounded p-4 flex flex-col md:w-[40%] w-[90%] gap-2"
	on:submit|preventDefault={handleSearch}
>
	<div class="w-full flex items-end">
		<TextInput
			Class="w-4/5"
			onInput={handleSearchInput}
			label=""
			max={null}
			search={true}
			placeholder={$_('Search groups')}
			bind:value={searchQuery}
		/>
	</div>
	<div class="flex flex-row items-center gap-1">
		<span>{$_('Sort')}: </span>
		<Select
			classInner="p-1 font-semibold"
			labels={[$_('All'), $_('Member'), $_('Not member')]}
			values={['all', 'member', 'not-member']}
			bind:value={filter.joined}
			onInput={handleChangeMember}
			innerLabel=""
		/>

		<div class="rounded-md p-1">
			<Button
				Class="!p-1 border-none text-red-600 cursor-pointer hover:underline"
				buttonStyle="warning-light"
				onClick={resetFilter}>{$_('Reset Filter')}</Button
			>
		</div>
	</div>
</form>

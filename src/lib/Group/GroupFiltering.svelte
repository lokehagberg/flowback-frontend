<script lang="ts">
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faMagnifyingGlass } from '@fortawesome/free-solid-svg-icons/faMagnifyingGlass';
	import Button from '$lib/Generic/Button.svelte';
	import type { GroupFilter } from './interface';

	export let filter: GroupFilter, getGroups: () => void;
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true;

	const handleChangeMember = (e: any) => {
		filter.joined = e.target.value;
		getGroups();
	};

	const handleSearch = () => {
		// console.log(filter)
		// filter.search = e.target.value;
		getGroups();
	};

	const resetFilter = () => {
		filter = { joined: 'all', search: '' };
		getGroups();
	};
</script>

<form
	class="bg-white dark:bg-darkobject dark:text-darkmodeText shadow rounded p-4 flex flex-col md:w-[40%] w-[90%] gap-2"
	on:submit|preventDefault={handleSearch}
>
	<div class="w-full flex items-end">
		<TextInput
			Class="w-4/5"
			onInput={() => {
				searched = false;
				handleSearch();
			}}
			label=""
			max={null}
			search={true}
			placeholder={$_('Search groups')}
			bind:value={filter.search}
		/>

		<!-- <Button
			Class={`w-7 h-7 ml-4 flex justify-center items-center ${
				searched ? 'bg-blue-300' : 'bg-blue-600'
			}`}
			type="submit"
		>
			<Fa icon={faMagnifyingGlass} />
		</Button> -->
	</div>
	<div class="flex flex-row items-center gap-1">
    <span>{$_('Sort')}: </span>
		<select
			on:input={handleChangeMember}
			class="rounded-sm m-1 p-1 border-0 font-semibold dark:border-gray-600 dark:bg-darkobject"
		>
			<option value="all">{$_('All')}</option>
			<option value="member">{$_('Member')}</option>
			<option value="not-member">{$_('Not member')}</option>
		</select>

		<div class="rounded-md p-1">
			<Button Class="!p-1 border-none text-red-600 cursor-pointer hover:underline" buttonStyle="warning-light" onClick={resetFilter}
				>{$_('Reset Filter')}</Button
			>
		</div>
	</div>
</form>

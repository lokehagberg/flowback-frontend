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
	import type { WorkGroup } from '../WorkingGroups/interface.js';

	export let filter: Filter,
		handleSearch = () => {},
		workGroups: WorkGroup[] = [];
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true;

	const resetFilter = () => {};

	const onWorkGroupChange = (workGroupId: number) => {
		filter.workgroup = workGroupId;
	};

	onMount(() => {});

	$: if (filter) handleSearch();
</script>

<form
	class="bg-white dark:bg-darkobject dark:text-darkmodeText shadow rounded p-4 flex flex-col w-full gap-4"
	on:submit|preventDefault={() => {
		searched = true;
		handleSearch();
	}}
>
	<div class="w-full flex items-end">
		<TextInput
			Class="w-4/5"
			onInput={() => (searched = false)}
			label={$_('Search')}
			bind:value={filter.search}
		/>
		<label class="block text-md" for="work-group">
			{$_('Work Group')}
		</label>
		<select
			style="width:100%"
			class="rounded p-1 border border-gray-300 dark:border-gray-600 dark:bg-darkobject text-gray-500"
			on:input={(e) => {
				//@ts-ignore
				onWorkGroupChange(e?.target?.value);
			}}
			id="work-group"
		>
			<option class="w-5" value={null}> {$_('Unassigned')} </option>

			{#each workGroups as group}
				<option class="w-5 text-black" value={group.id}>
					{elipsis(group.name)}
				</option>
			{/each}
		</select>

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

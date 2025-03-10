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
		Class = '',
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
	class="bg-white dark:bg-darkobject dark:text-darkmodeText shadow rounded p-4 flex flex-col w-full gap-4 ${Class}"
	on:submit|preventDefault={() => {
		searched = true;
		handleSearch();
	}}
>
	<div class="w-full flex items-end gap-4">
		<TextInput
			Class="flex-1"
			inputClass="placeholder-gray-600 pl-2 pr-6 text-gray-500 border-0 bg-gray-100 dark:bg-darkobject"
			placeholder={$_('Search tasks')}
			onInput={() => (searched = false)}
			label=""
			max={null}
			search={true}
			bind:value={filter.search}
		/>
		<div class="flex flex-row gap-2 flex-1 items-center">
			<label class="block text-md" for="work-group">
				{$_('Work Group')}:
			</label>
			<select
				style="width:100%"
				class="rounded p-1 dark:border-gray-600 dark:bg-darkobject text-gray-700 font-semibold"
				on:input={(e) => {
					//@ts-ignore
					onWorkGroupChange(e?.target?.value);
				}}
				id="work-group"
			>
				<option class="w-5" value={null}> {$_('None')} </option>

				{#each workGroups as group}
					<option class="w-5 text-black" value={group.id}>
						{elipsis(group.name)}
					</option>
				{/each}
			</select>
		</div>

		<Button
			Class={`w-8 h-8 !p-1 flex justify-center items-center ${
				searched ? 'bg-blue-300' : 'bg-blue-600'
			}`}
			type="submit"
		>
			<Fa icon={faMagnifyingGlass} />
		</Button>
	</div>
</form>

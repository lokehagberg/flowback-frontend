<script lang="ts">
	import TextInput from '$lib/Generic/TextInput.svelte';
	import type { Filter } from './interface';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faMagnifyingGlass } from '@fortawesome/free-solid-svg-icons/faMagnifyingGlass';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { Tag } from '$lib/Group/interface';
	import { homePolls as homePollsLimit } from '../Generic/APILimits.json';
	import Select from '$lib/Generic/Select.svelte';
	import { elipsis } from '$lib/Generic/GenericFunctions';

	export let filter: Filter,
		handleSearch: () => {},
		tagFiltering = false;
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true,
		tags: Tag[] = [];

	const handleFinishedSelection = (e: any) => {
		filter.finishedSelection = e.target.value;
	};

	const handleSort = (e: any) => {
		filter.order_by = e.target.value;
	};

	const handleTags = (e: any) => {
		if (e.target.value === 'null') filter.tag = null;
		else filter.tag = e.target.value;
	};

	const getTags = async () => {
		if (!$page.params.groupId) return;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/tags?limit=${homePollsLimit}`
		);
		if (!res.ok) return;
		tags = json.results;
	};

	const resetFilter = () => {
		filter = {
			search: '',
			finishedSelection: 'all',
			public: false,
			order_by: 'start_date_desc',
			tag: null
		};
	};

	onMount(() => {
		getTags();
	});

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

		<Button
			Class={`w-8 h-8 ml-4 !p-1 flex justify-center items-center ${
				searched ? 'bg-blue-300' : 'bg-blue-600'
			}`}
			type="submit"
		>
			<Fa icon={faMagnifyingGlass} />
		</Button>
	</div>
	<div class="flex">
		<Select
			Class="rounded-md p-1"
			onInput={handleFinishedSelection}
			values={['all', 'unfinished', 'finished']}
			labels={[$_('All'), $_('Ongoing'), $_('Done')]}
			bind:value={filter.finishedSelection}
		/>

		<Select
			Class="rounded-md p-1"
			onInput={handleSort}
			values={['start_date_desc', 'start_date_asc']}
			labels={[$_('Newest first'), $_('Oldest first')]}
			bind:value={filter.order_by}
		/>

		{#if tagFiltering}
			<div class="rounded-md p-1">
				<select on:input={handleTags} class="rounded-sm p-1 border border-gray-300 dark:border-gray-600 dark:bg-darkobject">
					<option value={null}>{$_('Any')}</option>
					{#each tags as tag}
						<option value={tag.id}>{elipsis(tag.name, 15)}</option>
					{/each}
				</select>
			</div>
		{/if}
		
		<div class="rounded-md p-1">
			<Button Class="!p-1 ml-1" buttonStyle="primary-light" action={resetFilter}
				>{$_('Reset Filter')}</Button
			>
		</div>

		<!-- <CheckboxButtons
			label={''}
			labels={[
				{ label: 'Finished', checked: false },
				{ label: 'Not Finished', checked: false }
			]}
		/>
	</div> -->
		<!--<CheckboxButtons label={''} labels={[{label:'Public', checked:true}, {label:'Private', checked:true}]} /> -->
	</div>
</form>

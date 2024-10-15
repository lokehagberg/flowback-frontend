<script lang="ts">
	import TextInput from '$lib/Generic/TextInput.svelte';
	import type { Filter } from './interface';
	import { _ } from 'svelte-i18n';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faMagnifyingGlass } from '@fortawesome/free-solid-svg-icons/faMagnifyingGlass';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { Tag } from '$lib/Group/interface';
	import { homePolls as homePollsLimit } from '../Generic/APILimits.json';
	import Select from '$lib/Generic/Select.svelte';

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
	class="bg-white dark:bg-darkobject dark:text-darkmodeText shadow rounded p-6 flex flex-col w-full gap-4"
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
	<div>
	
		<Select
			Class="dark:bg-darkbackground bg-gray-100 rounded-md p-1"
			onInput={handleFinishedSelection}
			values={['all', 'unfinished', 'finished']}
			labels={['All', 'Ongoing', 'Done']}
			bind:value={filter.finishedSelection}
		/>

		<Select
			Class="dark:bg-darkbackground bg-gray-100 rounded-md p-1"
			onInput={handleSort}
			values={['start_date_desc', 'start_date_asc']}
			labels={['Newest first', 'Oldest first']}
			bind:value={filter.order_by}
		/>


		{#if tagFiltering}
			<select on:input={handleTags} class="dark:bg-darkbackground bg-gray-100 rounded-md p-1">
				<option value={null}>{$_('Any')}</option>
				{#each tags as tag}
					<option value={tag.id}>{tag.name}</option>
				{/each}
			</select>
		{/if}

		<Button Class="p-2" action={resetFilter}>Reset Filter</Button>

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

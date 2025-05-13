<script lang="ts">
	import TextInput from '$lib/Generic/TextInput.svelte';
	import type { Filter } from './interface';
	import { _ } from 'svelte-i18n';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { Tag } from '$lib/Group/interface';
	import { homePolls as homePollsLimit } from '../Generic/APILimits.json';
	import Select from '$lib/Generic/Select.svelte';
	import CheckboxButtons from '$lib/Generic/CheckboxButtons.svelte';
	import { browser } from '$app/environment';
	import { elipsis } from '$lib/Generic/GenericFunctions';
	import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';
	import { env } from '$env/dynamic/public';

	export let filter: Filter,
		handleSearch: () => void,
		tagFiltering = false;

	// Add new export for content type filtering
	export let showThreads = true;
	export let showPolls = true;

	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true,
		tags: Tag[] = [],
		workGroups: WorkGroup[] = [],
		groupId = '1';

	// Initialize content type state from localStorage
	const initializeContentTypeState = () => {
		if (browser) {
			const savedState = localStorage.getItem('contentTypeState');
			if (savedState) {
				const { threads, polls } = JSON.parse(savedState);
				showThreads = threads;
				showPolls = polls;
				contentTypeLabels[0].checked = threads;
				contentTypeLabels[1].checked = polls;
			}
		}
	};

	const contentTypeLabels = [
		{ label: 'Threads', checked: true, id: 1 },
		{ label: 'Polls', checked: true, id: 2 }
	];

	const handleContentTypeChange = (id: number) => {
		if (id === 1) {
			showThreads = !showThreads;
			contentTypeLabels[0].checked = showThreads;
		} else if (id === 2) {
			showPolls = !showPolls;
			contentTypeLabels[1].checked = showPolls;
		}

		// Save to localStorage
		if (browser) {
			localStorage.setItem(
				'contentTypeState',
				JSON.stringify({
					threads: showThreads,
					polls: showPolls
				})
			);
		}
	};

	const handleFinishedSelection = (e: any) => {
		filter.finishedSelection = e.target.value;
	};

	const handleSort = (e: any) => {
		filter.order_by = e.target.value;
		handleSearch();
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

	const getWorkGroupList = async () => {
		const { res, json } = await fetchRequest('GET', `group/${groupId}/list`);

		if (!res.ok) return;
		workGroups = json.results.filter((group: WorkGroup) => group.joined === true);
	};

	const resetFilter = () => {
		filter = {
			search: '',
			finishedSelection: 'all',
			public: false,
			order_by: 'start_date_desc',
			tag: null,
			workgroup: null,
		};
		// Reset content type checkboxes
		showThreads = true;
		showPolls = true;
		contentTypeLabels[0].checked = true;
		contentTypeLabels[1].checked = true;

		// Update localStorage
		if (browser) {
			localStorage.setItem(
				'contentTypeState',
				JSON.stringify({
					threads: true,
					polls: true
				})
			);
		}
	};

	const onWorkGroupChange = (workGroupId: number) => {
		filter.workgroup = workGroupId;
	};

	onMount(() => {
		getTags();
		getWorkGroupList();
		initializeContentTypeState();

		groupId = env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' ? '1' : $page.params.groupId;
	});
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
			label=""
			max={null}
			search={true}
			placeholder={$_('Search polls')}
			bind:value={filter.search}
		/>
	</div>
	<div class="flex gap-4 flex-wrap items-center">
		<Select
			Class="rounded p-1 flex flex-row items-center gap-1"
			classInner="font-semibold border border-0"
			onInput={handleSort}
			values={['start_date_desc', 'start_date_asc']}
			labels={[$_('Newest first'), $_('Oldest first')]}
			label="{$_('Sort')}:"
			bind:value={filter.order_by}
			innerLabel={null}
		/>

		<CheckboxButtons
			label=""
			labels={contentTypeLabels}
			onChange={handleContentTypeChange}
			Class="flex items-center"
		/>

		{#if showThreads == true && showPolls == false}
			<div class="flex flex-row gap-2 items-center">
				<label class="block text-md whitespace-nowrap" for="work-group">
					{$_('Work Group')}:
				</label>
				<select
					style="width:100%"
					class="rounded p-1 dark:border-gray-600 dark:bg-darkobject font-semibold"
					on:input={(e) => {
						//@ts-ignore
						onWorkGroupChange(e?.target?.value);
						handleSearch();
					}}
					id="work-group"
				>
					<option class="w-5" value={0}> {$_('All')} </option>

					{#each workGroups as group}
						<option class="w-5" value={group.id}>
							{elipsis(group.name)}
						</option>
					{/each}
				</select>
			</div>
		{/if}

		<div class="rounded p-1">
			<Button
				Class="!p-1 border-none text-red-600 cursor-pointer hover:underline"
				buttonStyle="warning-light"
				onClick={resetFilter}
			>
				{$_('Reset Filter')}
			</Button>
		</div>
	</div>
</form>

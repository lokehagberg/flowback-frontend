<script lang="ts">
	import { userStore } from '$lib/User/interfaces';
	import KanbanEntry from './KanbanEntry.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { _ } from 'svelte-i18n';
	import { onDestroy, onMount } from 'svelte';
	import { kanban as kanbanLimit } from '../../Generic/APILimits.json';
	import CreateKanbanEntry from './CreateKanbanEntry.svelte';
	import type { WorkGroup } from '../WorkingGroups/interface';
	import Fa from 'svelte-fa';
	import { faPlus } from '@fortawesome/free-solid-svg-icons';
	import { type kanban } from './Kanban';
	import AdvancedFiltering from '$lib/Generic/AdvancedFiltering.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';

	const tags = ['', 'Backlog', 'To do', 'Current', 'Evaluation', 'Done'];

	let { Class = '' } = $props();

	let kanbanEntries: kanban[] = $state([]),
		interval: any,
		open = $state(false),
		search = $state(''),
		workGroups: WorkGroup[] = $state([]),
		lane: number = $state(1),
		groupIds: number[] = $state([]),
		workgroupIds: number[] = $state([]),
		userChecked = $state(false),
		assigneeId: number = $state(0);

	const removeKanbanEntry = (id: number) => {
		kanbanEntries.filter((entry) => entry.id !== id);
	};

	const getKanbanEntries = async () => {
		let _kanbanEntries = [];

		let filter = `&limit=${kanbanLimit}&order_by=priority_desc&title__icontains=${search}`;

		if (userChecked && (assigneeId === $userStore?.id || assigneeId === 0)) {
			let api = `user/kanban/entry/list?origin_type=user${filter}`;
			const { res, json } = await fetchRequest('GET', api);
			if (res.ok) {
				_kanbanEntries.push(json.results ?? []);
			}
		}
		if (assigneeId) filter += `&assignee=${assigneeId}`;

		if (groupIds.length > 0) {
			let apis = groupIds.map((id) =>
				fetchRequest(
					'GET',
					`user/kanban/entry/list?origin_type=group&${filter}&origin_id=${id}`
				)
			);

			let response = (await Promise.all(apis)).map(({ res, json }) => {
				if (res.ok) return json.results ?? [];
			});
			_kanbanEntries.push(response);
		}

		if (workgroupIds.length > 0) {
			let apis = workgroupIds.map((id) =>
				fetchRequest(
					'GET',
					`user/kanban/entry/list?${filter}&work_group_ids=${id}`
				)
			);
			let response = (await Promise.all(apis)).map(({ res, json }) => {
				if (res.ok) return json.results ?? [];
			});
			_kanbanEntries.push(response);
		}

		kanbanEntries = _kanbanEntries
			.flat(2)
			//@ts-ignore
			.sort((a, b) => a.priority < b.priority);
	};

	onMount(async () => {
		let groupId =
			Number(new URLSearchParams(document.location.search).get('groupId')) ??
			null;
		if (groupId) groupIds.push(groupId);
		else userChecked = true;

		await getKanbanEntries();

		interval = setInterval(() => {
			getKanbanEntries();
		}, 20000);
	});

	onDestroy(() => {
		clearInterval(interval);
	});

	$effect(() => {
		// A little ugly, but the "or" operator doesn't work
		if (workgroupIds) getKanbanEntries();
		if (groupIds) getKanbanEntries();
		if (userChecked) getKanbanEntries();
		if (assigneeId) getKanbanEntries();
	});
</script>

<div
	id="kanban-board"
	class={'dark:bg-darkobject dark:text-darkmodeText p-2 pt-4 break-words' +
		Class}
>
	<AdvancedFiltering
		bind:assigneeId
		bind:groupIds
		bind:workgroupIds
		bind:userChecked
	/>

	<TextInput
		Class="flex-1 h-full placeholder-gray-600 rounded text-gray-500 bg-gray-100 dark:bg-darkobject dark:text-darkmodeText"
		inputClass="placeholder-gray-600 text-gray-500 border-0 bg-gray-100 dark:bg-darkobject dark:text-darkmodeText"
		placeholder={$_('Search tasks')}
		on:change={async () => {
			getKanbanEntries();
		}}
		label="Search"
		bind:value={search}
	/>
	<div class="flex overflow-x-auto py-3">
		{#each tags as _tag, i}
			{#if i !== 0}
				<div
					id={`${_tag}-kanban-lane`}
					class="bg-white w-[15vw] max-w-[250px] p-2 m-1 dark:bg-darkbackground dark:text-darkmodeText border-gray-200 rounded shadow flex flex-col"
				>
					<div class="flex justify-between pb-3">
						<span class="xl:text-md md:text-sm p-1 font-medium">{$_(_tag)}</span
						>
						<button
							id={`${_tag}-add`}
							class="text-sm p-1"
							onclick={() => {
								open = true;
								lane = i;
							}}><Fa icon={faPlus} size="12px" /></button
						>
					</div>

					<ul class="flex flex-col gap-2 flex-grow overflow-y-auto">
						{#each kanbanEntries as kanban, j}
							{#if kanban?.lane === i}
								<KanbanEntry
									bind:kanban={kanbanEntries[j]}
									bind:workGroups
									{removeKanbanEntry}
									{getKanbanEntries}
								/>
							{/if}
						{/each}
					</ul>

					<div class="flex justify-between pt-4">
						<button
							class="text-sm flex items-center gap-2"
							onclick={() => {
								open = true;
								lane = i;
							}}
						>
							<span class="text-gray-600 dark:text-darkmodeText"
								>+ {$_('Add a task')}</span
							>
						</button>
					</div>
				</div>
			{/if}
		{/each}
	</div>
</div>

<CreateKanbanEntry bind:open bind:workGroups bind:lane {getKanbanEntries} />

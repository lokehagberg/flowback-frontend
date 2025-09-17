<script lang="ts">
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import KanbanEntry from './KanbanEntry.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { _ } from 'svelte-i18n';
	import type { GroupUser } from '../interface';
	import { onDestroy, onMount } from 'svelte';
	import { kanban as kanbanLimit } from '../../Generic/APILimits.json';
	import CreateKanbanEntry from './CreateKanbanEntry.svelte';
	import type { WorkGroup } from '../WorkingGroups/interface';
	import Fa from 'svelte-fa';
	import { faPlus } from '@fortawesome/free-solid-svg-icons';
	import type { kanban, Filter } from './Kanban';
	import KanbanFiltering from './KanbanFiltering.svelte';
	import { page } from '$app/stores';
	import { userStore } from '$lib/User/interfaces';

	const tags = ['', 'Backlog', 'To do', 'Current', 'Evaluation', 'Done'];

	export let Class = '';

	let kanbanEntries: kanban[] = [],
		assignee: number | null = null,
		users: GroupUser[] = [],
		interval: any,
		open = false,
		numberOfOpen = 0,
		filter: Filter = {
			group: $page.url.searchParams.get('groupId'),
			assignee: null,
			search: '',
			workgroup: null,
			type: $page.url.searchParams.get('groupId') ? 'group' : 'home'
		},
		workGroups: WorkGroup[] = [],
		lane: number = 1,
		// Add filteredKanbanEntries to store the client-side filtered result
		filteredKanbanEntries: kanban[] = [];

	const changeNumberOfOpen = (addOrSub: 'Addition' | 'Subtraction') => {
		if (numberOfOpen < 0) numberOfOpen = 0;

		if (addOrSub === 'Addition') numberOfOpen += 1;
		if (addOrSub === 'Subtraction') numberOfOpen -= 1;
	};

	const getKanbanEntries = async () => {
		if (filter.type === 'group') {
			await getKanbanEntriesGroup();
		} else if (filter.type === 'home') {
			await getKanbanEntriesHome();
		}

		// Apply client-side filtering after fetching
		filterKanbanEntries();
	};

	const getKanbanEntriesGroup = async () => {
		if (!filter.group) {
			kanbanEntries = [];
			return;
		}

		let api = `group/${filter.group}/kanban/entry/list?limit=${kanbanLimit}&order_by=priority_desc`;
		if (filter.assignee) api += `&assignee=${filter.assignee}`;
		if (filter.search !== '') api += `&title__icontains=${filter.search}`;
		if (filter.workgroup) api += `&work_group_ids=${filter.workgroup}`;

		const { res, json } = await fetchRequest('GET', api);

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Failed to fetch kanban tasks', success: false });
			return;
		}

		kanbanEntries = json.results;
	};

	const getKanbanEntriesHome = async () => {
		let api = `user/kanban/entry/list?limit=${kanbanLimit}&order_by=priority_desc`;
		if (filter.search !== '')
			api += `&title__icontains=${filter.search}&description__icontains=${filter.search}`;

		const { res, json } = await fetchRequest('GET', api);

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Failed to fetch kanban tasks', success: false });
			return;
		}
		
		kanbanEntries = json.results;
	};

	const getGroupUsers = async () => {
		let api = `group/${filter.group}/users?limit=${kanbanLimit}`;

		const { json, res } = await fetchRequest('GET', api);
		if (!res.ok) return;

		users = json?.results;
	};

	const getWorkGroupList = async () => {
		const { res, json } = await fetchRequest('GET', `group/${filter.group}/list`);

		if (!res.ok) return;
		workGroups = json?.results.filter((group: WorkGroup) => group.joined === true);

		workGroups.forEach((workgroup) => {
			workgroup.group_id = Number(filter.group);
		});
	};

	const removeKanbanEntry = (id: number) => {
		kanbanEntries = kanbanEntries.filter((entry) => entry.id !== id);
		// Reapply filtering after removal
		filterKanbanEntries();
	};

	// New client-side filtering function
	const filterKanbanEntries = () => {
		filteredKanbanEntries = kanbanEntries.filter((entry) => {
			const matchesSearch =
				!filter.search ||
				entry.title?.toLowerCase().includes(filter.search.toLowerCase()) ||
				entry.description?.toLowerCase().includes(filter.search.toLowerCase());
			const matchesWorkgroup = !filter.workgroup || entry.work_group?.id === filter.workgroup;
			return matchesSearch && matchesWorkgroup;
		});
	};

	onMount(async () => {
		assignee = $userStore?.id || -1;
		await getKanbanEntries();
		await getWorkGroupList();
		await getGroupUsers();

		interval = setInterval(async () => {
			if (numberOfOpen === 0) await getKanbanEntries();
		}, 20410);
	});

	onDestroy(() => {
		clearInterval(interval);
	});

	$: filter.group && getWorkGroupList();
	$: filter.group && getGroupUsers();

	$: if (filter.type) getKanbanEntries();
</script>

<div
	id="kanban-board"
	class={'dark:bg-darkobject dark:text-darkmodeText p-2 pt-4 break-words' + Class}
>
	<KanbanFiltering bind:workGroups bind:filter handleSearch={getKanbanEntries} Class="" />
	<div class="flex overflow-x-auto py-3">
		{#each tags as _tag, i}
			{#if i !== 0}
				<div
					id={`${_tag}-kanban-lane`}
					class="bg-white w-[15vw] max-w-[250px] p-2 m-1 dark:bg-darkbackground dark:text-darkmodeText border-gray-200 rounded shadow flex flex-col"
				>
					<div class="flex justify-between pb-3">
						<span class="xl:text-md md:text-sm p-1 font-medium">{$_(_tag)}</span>
						<button
							id={`${_tag}-add`}
							class="text-sm p-1"
							on:click={() => {
								open = true;
								lane = i;
							}}><Fa icon={faPlus} size="12px" /></button
						>
					</div>
					<ul class="flex flex-col gap-2 flex-grow overflow-y-auto">
						{#if filteredKanbanEntries?.length > 0}
							{#each filteredKanbanEntries as kanban}
								{#if kanban.lane === i}
									<KanbanEntry
										bind:workGroups
										bind:kanban
										bind:filter
										{users}
										{removeKanbanEntry}
										{changeNumberOfOpen}
										{getKanbanEntries}
									/>
								{/if}
							{/each}
						{/if}
					</ul>
					<div class="flex justify-between pt-4">
						<button
							class="text-sm flex items-center gap-2"
							on:click={() => {
								open = true;
								lane = i;
							}}
						>
							<span class="text-gray-600 dark:text-darkmodeText">+ {$_('Add a task')}</span>
						</button>
					</div>
				</div>
			{/if}
		{/each}
	</div>
</div>

<CreateKanbanEntry
	groupId={filter.group || ''}
	bind:open
	bind:filter
	bind:kanbanEntries
	bind:users
	bind:workGroups
	bind:lane
	{getKanbanEntries}
/>

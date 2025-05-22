<script lang="ts">
	import KanbanEntry from './KanbanEntry.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { _ } from 'svelte-i18n';
	import type { GroupUser } from '../interface';
	import { onDestroy, onMount } from 'svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { kanban as kanbanLimit } from '../../Generic/APILimits.json';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import CreateKanbanEntry from './CreateKanbanEntry.svelte';
	import type { WorkGroup } from '../WorkingGroups/interface';
	import Fa from 'svelte-fa';
	import { faPlus } from '@fortawesome/free-solid-svg-icons';
	import type { kanban, Filter } from './Kanban';
	import KanbanFiltering from './KanbanFiltering.svelte';
	import { env } from '$env/dynamic/public';
	import { page } from '$app/stores';
	import { userInfo } from '$lib/Generic/GenericFunctions';

	const tags = ['', 'Backlog', 'To do', 'Current', 'Evaluation', 'Done'];

	let kanbanEntries: kanban[] = [],
		assignee: number | null = null,
		users: GroupUser[] = [],
		status: StatusMessageInfo,
		poppup: poppup,
		interval: any,
		open = false,
		numberOfOpen = 0,
		filter: Filter = {
			assignee: null,
			search: '',
			workgroup: null
		},
		workGroups: WorkGroup[] = [],
		lane: number = 1,
		groupId = '1',
		// Add filteredKanbanEntries to store the client-side filtered result
		filteredKanbanEntries: kanban[] = [];

	export let type: 'home' | 'group',
		Class = '';

	const changeNumberOfOpen = (addOrSub: 'Addition' | 'Subtraction') => {
		if (numberOfOpen < 0) numberOfOpen = 0;

		if (addOrSub === 'Addition') numberOfOpen += 1;
		if (addOrSub === 'Subtraction') numberOfOpen -= 1;
	};

	const getKanbanEntries = async () => {
		if (type === 'group') {
			kanbanEntries = await getKanbanEntriesGroup();
		} else if (type === 'home') {
			await getKanbanEntriesHome();
		}
		// Apply client-side filtering after fetching
		filterKanbanEntries();
	};

	const getKanbanEntriesGroup = async () => {
		let api = `group/${groupId}/kanban/entry/list?limit=${kanbanLimit}&order_by=priority_desc`;
		if (filter.assignee !== null) api += `&assignee=${filter.assignee}`;
		if (filter.search !== '') api += `&title__icontains=${filter.search}`;
		if (filter.workgroup !== null) api += `&work_group_ids=${filter.workgroup}`;

		const { res, json } = await fetchRequest('GET', api);
		if (!res.ok) status = statusMessageFormatter(res, json);
		return json.results || [];
	};

	const getKanbanEntriesHome = async () => {
		let api = `user/kanban/entry/list?limit=${kanbanLimit}&order_by=priority_desc`;
		if (filter.search !== '') api += `&title__icontains=${filter.search}&description__icontains=${filter.search}`;

		const { res, json } = await fetchRequest('GET', api);

		if (!res.ok) status = statusMessageFormatter(res, json);
		kanbanEntries = json.results || [];
	};

	const getGroupUsers = async () => {
		let api = `group/${groupId}/users?limit=${kanbanLimit}`;

		const { json, res } = await fetchRequest('GET', api);
		if (!res.ok) return [];
		return json.results;
	};

	const getWorkGroupList = async () => {
		const { res, json } = await fetchRequest('GET', `group/${groupId}/list`);

		if (!res.ok) return;
		workGroups = json.results.filter((group: WorkGroup) => group.joined === true);
	};

	const removeKanbanEntry = (id: number) => {
		kanbanEntries = kanbanEntries.filter((entry) => entry.id !== id);
		// Reapply filtering after removal
		filterKanbanEntries();
	};

	// New client-side filtering function
	const filterKanbanEntries = () => {
		filteredKanbanEntries = kanbanEntries.filter((entry) => {
			const matchesSearch = !filter.search || 
				(entry.title?.toLowerCase().includes(filter.search.toLowerCase()) || 
				 entry.description?.toLowerCase().includes(filter.search.toLowerCase()));
			const matchesWorkgroup = !filter.workgroup || 
				(entry.work_group?.id === filter.workgroup);
			return matchesSearch && matchesWorkgroup;
		});
	};

	onMount(async () => {
		assignee = Number(localStorage.getItem('userId')) || 1;
		await getKanbanEntries();
		await getWorkGroupList();
		users = await getGroupUsers();

		interval = setInterval(async () => {
			if (numberOfOpen === 0) await getKanbanEntries();
		}, 20000);

		groupId = env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' ? '1' : $page.params.groupId;
	});

	onDestroy(() => {
		clearInterval(interval);
	});
</script>

<Poppup bind:poppup />

<div
	class={' dark:bg-darkobject dark:text-darkmodeText p-2 pt-4 break-words md:max-w-[calc(500px*5)]' +
		Class}
>
	<KanbanFiltering bind:workGroups bind:filter handleSearch={getKanbanEntries} Class="" />

	<div class="flex overflow-x-auto py-3">
		{#each tags as _tag, i}
			{#if i !== 0}
				<div
					class="bg-white min-w-[160px] md:min-w[170px] lg:min-w-[200px] max-w-[230px] p-2 m-1 dark:bg-darkbackground dark:text-darkmodeText border-gray-200 rounded shadow flex flex-col"
				>
					<div class="flex justify-between pb-3">
						<span class="xl:text-md md:text-sm p-1 font-medium">{$_(_tag)}</span>
						<button
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
										{users}
										{type}
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
							<span class="text-gray-600">+ {$_('Add a task')}</span>
						</button>
					</div>
				</div>
			{/if}
		{/each}
	</div>
</div>

<CreateKanbanEntry
	{groupId}
	bind:open
	{type}
	bind:kanbanEntries
	{users}
	bind:workGroups
	bind:lane
	{getKanbanEntries}
/>
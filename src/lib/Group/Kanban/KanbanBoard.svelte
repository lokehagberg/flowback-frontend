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
	import { isMobile } from '$lib/utils/isMobile';

	const tags = ['', 'Backlog', 'To do', 'Current', 'Evaluation', 'Done'];
	const laneColors = [
		'',
		'#9CA3AF',
		'#60A5FA',
		'#A78BFA',
		'#FBBF24',
		'#34D399'
	];

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
		assigneeId: number = $state(0),
		draggingOverLane: number | null = $state(null),
		activeLane: number = $state(1);

	const updateKanbanLaneFromDrop = async (
		entryId: number,
		targetLane: number
	) => {
		const entry = kanbanEntries.find((e) => e.id === entryId);
		if (!entry || entry.lane === targetLane) return;

		const { res } = await fetchRequest(
			'POST',
			entry.origin_type === 'group'
				? `group/${entry.origin_id}/kanban/entry/update`
				: 'user/kanban/entry/update',
			{ lane: targetLane, entry_id: entryId }
		);

		if (res.ok) await getKanbanEntries();
	};

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
	class={'dark:bg-darkobject bg-white mt-2 dark:text-darkmodeText p-2 pt-4 break-words' +
		Class}
>
	<!-- Toolbar -->
	<div class="flex items-center gap-2 mb-3">
		<AdvancedFiltering
			bind:assigneeId
			bind:groupIds
			bind:workgroupIds
			bind:userChecked
		/>
		<TextInput
			Class="flex-1 placeholder-gray-600 rounded text-gray-500 bg-gray-100 dark:bg-darkobject dark:text-darkmodeText"
			inputClass="placeholder-gray-600 text-gray-500 border-0 dark:bg-darkobject dark:text-darkmodeText"
			placeholder={$_('Search tasks')}
			on:change={async () => {
				getKanbanEntries();
			}}
			label=""
			bind:value={search}
		/>
	</div>

	<!-- Mobile: lane tab bar -->
	{#if $isMobile}
		<div class="flex gap-1.5 overflow-x-auto pb-2">
			{#each tags as _tag, i}
				{#if i !== 0}
					{@const count = kanbanEntries.filter((e) => e?.lane === i).length}
					<button
						class="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm font-medium whitespace-nowrap transition-colors flex-shrink-0
						{activeLane === i
							? 'text-white shadow-sm'
							: 'bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-400'}"
						style={activeLane === i ? `background-color: ${laneColors[i]}` : ''}
						onclick={() => (activeLane = i)}
					>
						{$_(_tag)}
						<span class="text-xs opacity-75 font-normal">{count}</span>
					</button>
				{/if}
			{/each}
		</div>

		<!-- Mobile: single active lane -->
		{#if true}
			{@const count = kanbanEntries.filter(
				(e) => e?.lane === activeLane
			).length}
			<div
				class="flex flex-col rounded-xl border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-darkbackground overflow-hidden shadow-sm"
			>
				<div
					class="px-3 py-2.5 flex items-center justify-between"
					style="border-top: 3px solid {laneColors[activeLane]}"
				>
					<div class="flex items-center gap-2">
						<span
							class="font-semibold text-sm text-gray-700 dark:text-darkmodeText"
							>{$_(tags[activeLane])}</span
						>
						<span
							class="text-xs bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-300 rounded-full px-2 py-0.5 font-medium"
							>{count}</span
						>
					</div>
					<button
						class="w-7 h-7 rounded-full bg-gray-200 dark:bg-gray-600 flex items-center justify-center hover:bg-gray-300 dark:hover:bg-gray-500 transition-colors text-gray-600 dark:text-gray-200"
						onclick={() => {
							open = true;
							lane = activeLane;
						}}><Fa icon={faPlus} size="sm" /></button
					>
				</div>

				<ul
					class="flex flex-col gap-2 p-2 flex-grow overflow-y-auto min-h-[120px]"
				>
					{#each kanbanEntries as kanban, j}
						{#if kanban?.lane === activeLane}
							<KanbanEntry
								bind:kanban={kanbanEntries[j]}
								bind:workGroups
								{removeKanbanEntry}
								{getKanbanEntries}
							/>
						{/if}
					{/each}
				</ul>

				<div class="px-2 pb-2">
					<button
						class="w-full text-sm text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg py-2 flex items-center justify-center gap-1 transition-colors"
						onclick={() => {
							open = true;
							lane = activeLane;
						}}
					>
						<span class="text-base leading-none">+</span>
						<span>{$_('Add a task')}</span>
					</button>
				</div>
			</div>
		{/if}
	{/if}
	<!-- Desktop: all lanes side by side -->
	<div class="hidden md:flex overflow-x-auto py-3 gap-2">
		{#each tags as _tag, i}
			{#if i !== 0}
				{@const count = kanbanEntries.filter((e) => e?.lane === i).length}
				<div
					id={`${_tag}-kanban-lane`}
					class="min-w-[200px] w-[15vw] max-w-[260px] flex flex-col rounded-xl border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-darkbackground overflow-hidden shadow-sm {draggingOverLane ===
					i
						? 'ring-2 ring-blue-400 dark:ring-blue-500 bg-blue-50 dark:bg-blue-900/20'
						: ''}"
					ondragenter={(e) => {
						e.preventDefault();
						draggingOverLane = i;
					}}
					ondragleave={(e) => {
						if (
							!(e.currentTarget as HTMLElement).contains(
								e.relatedTarget as Node
							)
						)
							draggingOverLane = null;
					}}
					ondragover={(e) => {
						e.preventDefault();
					}}
					ondrop={async (e) => {
						e.preventDefault();
						draggingOverLane = null;
						const entryId = Number(e.dataTransfer?.getData('text/plain'));
						if (entryId) await updateKanbanLaneFromDrop(entryId, i);
					}}
				>
					<!-- Lane header -->
					<div
						class="px-3 py-2.5 flex items-center justify-between"
						style="border-top: 3px solid {laneColors[i]}"
					>
						<div class="flex items-center gap-2">
							<span
								class="font-semibold text-sm text-gray-700 dark:text-darkmodeText"
								>{$_(_tag)}</span
							>
							<span
								class="text-xs bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-300 rounded-full px-2 py-0.5 font-medium"
								>{count}</span
							>
						</div>
						<button
							id={`${_tag}-add`}
							class="w-6 h-6 rounded-full bg-gray-200 dark:bg-gray-600 flex items-center justify-center hover:bg-gray-300 dark:hover:bg-gray-500 transition-colors text-gray-600 dark:text-gray-200"
							onclick={() => {
								open = true;
								lane = i;
							}}><Fa icon={faPlus} size="10px" /></button
						>
					</div>

					<!-- Cards list -->
					<ul
						class="flex flex-col gap-2 p-2 flex-grow overflow-y-auto min-h-[80px]"
					>
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

					<!-- Add task footer -->
					<div class="px-2 pb-2">
						<button
							class="w-full text-sm text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg py-1.5 flex items-center gap-1 transition-colors"
							onclick={() => {
								open = true;
								lane = i;
							}}
						>
							<span class="text-base leading-none">+</span>
							<span>{$_('Add a task')}</span>
						</button>
					</div>
				</div>
			{/if}
		{/each}
	</div>
</div>

<CreateKanbanEntry bind:open bind:workGroups bind:lane {getKanbanEntries} />

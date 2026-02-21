<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import Modal from '$lib/Generic/Modal.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import type { Group } from '$lib/Group/interface';
	import type { User } from '$lib/User/interfaces';
	import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';
	import { onMount } from 'svelte';
	import { groupStore, workgroupStore } from '$lib/Group/Kanban/Kanban';
	import Fa from 'svelte-fa';
	import {
		faFilter,
		faUser,
		faPeopleGroup,
		faPeopleCarryBox
	} from '@fortawesome/free-solid-svg-icons';

	interface Props {
		groupIds: number[];
		workgroupIds: number[];
		userChecked: boolean;
		assigneeId?: number;
	}

	let {
		groupIds = $bindable(),
		workgroupIds = $bindable(),
		userChecked = $bindable(),
		assigneeId = $bindable()
	}: Props = $props();

	let openFilter = $state(false),
		groups: Group[] = $state([]),
		workgroups: WorkGroup[] = $state([]),
		users: User[] = $state([]);

	const getGroups = async () => {
		let urlFilter = '';
		const { res, json } = await fetchRequest(
			'GET',
			`group/list?limit=50&${urlFilter}&joined=true`
		);

		if (!res.ok) return;

		groups = json?.results;
		groupStore.set(groups);
	};

	const getWorkgroups = async () => {
		// Creates a list of promises to fetch workgroups for each groupId
		const workgroupsPromise = groups.map((g) =>
			fetchRequest('GET', `group/${g.id}/list`)
		);
		let hasError = false;
		// Fetches all workgroups concurrently and makes sure all events are in one neat array
		workgroups = (await Promise.all(workgroupsPromise))
			.map(({ res, json }) => {
				if (!res.ok) {
					hasError = true;
					return [];
				} else return json.results;
			})
			.flat(1);

		// If any of the workgroup fetches failed, we set an error message
		if (hasError)
			ErrorHandlerStore.set({
				message: 'Failed to fetch atleast some workgroups',
				success: false
			});

		$workgroupStore = workgroups;
	};

	const getUsers = async () => {
		const { res, json } = await fetchRequest('GET', 'users?limit=1000');

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to fetch users',
				success: false
			});
			return;
		}

		users = json?.results ?? [];
	};

	const activeFilterCount = $derived(
		(userChecked ? 1 : 0) +
			groupIds.length +
			workgroupIds.length +
			(assigneeId ? 1 : 0)
	);

	onMount(async () => {
		await getGroups();
		await getWorkgroups();
		await getUsers();
	});
</script>

<Modal bind:open={openFilter} Class="max-w-[520px]">
	<div slot="header">
		<div
			class="flex items-center gap-2 pb-2 border-b border-gray-200 dark:border-gray-600"
		>
			<div
				class="w-8 h-8 rounded-lg bg-primary/10 flex items-center justify-center"
			>
				<Fa icon={faFilter} class="text-primary" size="sm" />
			</div>
			<h2 class="text-base font-semibold text-gray-800 dark:text-darkmodeText">
				{$_('Advanced Filter')}
			</h2>
		</div>
	</div>

	<div slot="body" class="flex flex-col gap-4 text-left w-full">
		<!-- Sources section -->
		<div>
			<p
				class="text-xs font-semibold uppercase tracking-wider text-gray-400 dark:text-gray-500 mb-2"
			>
				{$_('Sources')}
			</p>
			<div class="flex flex-col gap-1">
				<!-- Personal tasks -->
				<label
					class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700/50 cursor-pointer transition-colors group"
				>
					<input
						type="checkbox"
						bind:checked={userChecked}
						class="w-4 h-4 rounded border-gray-300 dark:border-gray-600 text-primary accent-primary cursor-pointer"
					/>
					<div class="flex items-center gap-2 flex-1 min-w-0">
						<Fa
							icon={faUser}
							class="text-gray-400 dark:text-gray-500 shrink-0"
							size="sm"
						/>
						<span
							class="text-sm text-gray-700 dark:text-darkmodeText font-medium"
						>
							{$_('Personal tasks')}
						</span>
					</div>
				</label>

				<!-- Groups -->
				{#each groups as group}
					<div>
						<label
							class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700/50 cursor-pointer transition-colors"
						>
							<input
								type="checkbox"
								onchange={() => {
									if (groupIds.includes(group.id)) {
										groupIds = groupIds.filter((id) => id !== group.id);
									} else {
										groupIds = [...groupIds, group.id];
									}
								}}
								checked={groupIds.includes(group.id)}
								class="w-4 h-4 rounded border-gray-300 dark:border-gray-600 accent-primary cursor-pointer"
							/>
							<div class="flex items-center gap-2 flex-1 min-w-0">
								<Fa
									icon={faPeopleGroup}
									class="text-gray-400 dark:text-gray-500 shrink-0"
									size="sm"
								/>
								<span
									class="text-sm text-gray-700 dark:text-darkmodeText font-medium truncate"
								>
									{group.name}
								</span>
							</div>
						</label>

						{#each workgroups.filter((w) => w.group_id === group.id) as workgroup}
							<label
								class="flex items-center gap-3 pl-10 pr-3 py-1.5 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700/50 cursor-pointer transition-colors"
							>
								<input
									type="checkbox"
									onchange={() => {
										if (workgroupIds.includes(workgroup.id)) {
											workgroupIds = workgroupIds.filter(
												(id) => id !== workgroup.id
											);
										} else {
											workgroupIds = [...workgroupIds, workgroup.id];
										}
									}}
									checked={workgroupIds.includes(workgroup.id)}
									class="w-4 h-4 rounded border-gray-300 dark:border-gray-600 accent-primary cursor-pointer"
								/>
								<div class="flex items-center gap-2 flex-1 min-w-0">
									<Fa
										icon={faPeopleCarryBox}
										class="text-gray-400 dark:text-gray-500 shrink-0"
										size="xs"
									/>
									<span
										class="text-sm text-gray-500 dark:text-gray-400 truncate"
									>
										{workgroup.name}
									</span>
								</div>
							</label>
						{/each}
					</div>
				{/each}
			</div>
		</div>

		<!-- Assignee section -->
		{#if users.length > 0}
			<div>
				<p
					class="text-xs font-semibold uppercase tracking-wider text-gray-400 dark:text-gray-500 mb-2"
				>
					{$_('Assignee')}
				</p>
				<div class="flex flex-wrap gap-2">
					{#each [{ id: 0, username: $_('Anyone') }, ...users.filter((u) => u.is_active)] as user}
						<button
							class="px-3 py-1.5 rounded-full text-sm border transition-colors {assigneeId ===
							user.id
								? 'bg-primary text-white border-primary'
								: 'bg-white dark:bg-darkobject border-gray-200 dark:border-gray-600 text-gray-600 dark:text-gray-300 hover:border-primary hover:text-primary dark:hover:text-primary'}"
							onclick={() => (assigneeId = user.id)}
						>
							{user.username}
						</button>
					{/each}
				</div>
			</div>
		{/if}
	</div>
</Modal>

<!-- Trigger button -->
<button
	onclick={() => (openFilter = true)}
	class="flex items-center gap-2 px-3 py-2 rounded-lg border transition-colors text-sm font-medium
		{activeFilterCount > 0
		? 'bg-primary text-white border-primary hover:brightness-95'
		: 'bg-white dark:bg-darkobject border-gray-200 dark:border-gray-600 text-gray-600 dark:text-darkmodeText hover:border-primary hover:text-primary dark:hover:text-primary'}"
>
	<Fa icon={faFilter} size="sm" />
	<span>{$_('Filter')}</span>
	{#if activeFilterCount > 0}
		<span
			class="flex items-center justify-center w-5 h-5 rounded-full bg-white/25 text-xs font-bold leading-none"
		>
			{activeFilterCount}
		</span>
	{/if}
</button>

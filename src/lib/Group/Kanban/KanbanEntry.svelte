<script lang="ts">
	import { userStore } from '$lib/User/interfaces';
	import { groupStore } from '$lib/Group/Kanban/Kanban';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { fade } from 'svelte/transition';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { checkForLinks, elipsis } from '$lib/Generic/GenericFunctions';
	import type { GroupUser } from '../interface';
	import { onMount } from 'svelte';
	import TimeAgo from 'javascript-time-ago';
	import KanbanIcons from './PriorityIcons.svelte';
	import PriorityIcons from './PriorityIcons.svelte';
	import { goto } from '$app/navigation';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import type { kanbanEdited, kanban } from './Kanban';
	import type { WorkGroup } from '../WorkingGroups/interface';
	import { env } from '$env/dynamic/public';
	import { faArrowLeft, faArrowRight, faCalendar } from '@fortawesome/free-solid-svg-icons';
	import Select from '$lib/Generic/Select.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import FileUploads from '$lib/Generic/File/FileUploads.svelte';
	import GroupSelection from '$lib/Generic/GroupSelection.svelte';
	import { groupMembers as groupMembersLimit } from '$lib/Generic/APILimits.json';

	export let kanban: kanban,
		removeKanbanEntry: (id: number) => void,
		workGroups: WorkGroup[] = [],
		getKanbanEntries: () => Promise<void>,
		toRemove: number[] = [];

	let users: GroupUser[] = [];

	const lanes = ['', 'Backlog', 'To do', 'In progress', 'Evaluation', 'Done'];
	const laneColors = ['', '#9CA3AF', '#60A5FA', '#A78BFA', '#FBBF24', '#34D399'];

	const priorityBorderColors: Record<number, string> = {
		1: '#9CA3AF',
		2: '#6EE7B7',
		3: '#60A5FA',
		4: '#FB923C',
		5: '#EF4444'
	};

	let isDragging = false;

	let openModal = false,
		selectedEntry: number,
		priorities = [5, 4, 3, 2, 1],
		priorityText = [
			$_('Very high priority'),
			$_('High priority'),
			$_('Medium priority'),
			$_('Low priority'),
			$_('Very low priority')
		],
		isEditing = false,
		innerWidth: number,
		outerWidth: number,
		kanbanEdited: kanbanEdited = {
			entry_id: kanban.id,
			description: kanban.description,
			title: kanban.title,
			assignee_id: kanban.assignee?.id,
			priority: kanban.priority || 3,
			end_date: formatDateForInput(kanban.end_date),
			work_group: kanban.work_group || null,
			attachments: kanban.attachments || []
		},
		images: File[],
		endDate: TimeAgo,
		selectedWorkgroupId: null | Number = null,
		selectedGroupId: null | Number = null;

	// Helper function to format date for datetime-local input
	function formatDateForInput(
		dateStr: string | null | undefined
	): string | null {
		if (!dateStr || isNaN(new Date(dateStr).getTime())) return null;

		const date = new Date(dateStr);
		// Adjust for local timezone by using local methods
		const year = date.getFullYear();
		const month = String(date.getMonth() + 1).padStart(2, '0');
		const day = String(date.getDate()).padStart(2, '0');
		const hours = String(date.getHours()).padStart(2, '0');
		const minutes = String(date.getMinutes()).padStart(2, '0');

		return `${year}-${month}-${day}T${hours}:${minutes}`;
	}

	const initializeKanbanEdited = () => {
		kanbanEdited = {
			entry_id: kanban.id,
			description: kanban.description,
			title: kanban.title,
			assignee_id: kanban.assignee?.id,
			priority: kanban.priority || 3,
			end_date: formatDateForInput(kanban.end_date),
			work_group: kanban.work_group || null,
			attachments: kanban.attachments || []
		};
	};

	const updateKanbanEntry = async () => {
		const formData = new FormData();

		formData.append('title', kanbanEdited.title);
		formData.append('tag', kanban.lane.toString());
		formData.append('lane', kanban.lane.toString());
		formData.append('entry_id', kanban.id.toString());
		formData.append('description', kanbanEdited.description || '');

		if (kanbanEdited.assignee_id)
			formData.append('assignee_id', kanbanEdited.assignee_id.toString());
		if (kanbanEdited.priority)
			formData.append('priority', kanbanEdited.priority.toString());

		if (selectedWorkgroupId)
			formData.append('work_group_id', selectedWorkgroupId?.toString() ?? '');

		if (selectedGroupId)
			formData.append('group_id', selectedGroupId?.toString() ?? '');

		if (kanbanEdited.end_date) {
			const _endDate = new Date(kanbanEdited.end_date);
			const isoDate = _endDate.toISOString();
			const dateString = `${isoDate.slice(0, 10)}T${_endDate.getHours()}:${_endDate.getMinutes()}`;
			formData.append('end_date', dateString);
		} else {
			formData.append('end_date', '');
		}

		if (toRemove.toString() && toRemove.toString() !== '')
			formData.append('attachments_remove', toRemove.toString());

		if (images) {
			images.forEach((image) => {
				if (image instanceof File) formData.append('attachments_add', image);
			});
		}

		const { res, json } = await fetchRequest(
			'POST',
			kanban.origin_type === 'group'
				? `group/${kanban.origin_id}/kanban/entry/update`
				: 'user/kanban/entry/update',
			formData,
			true,
			false
		);

		isEditing = false;

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to update kanban task',
				success: false
			});
			return;
		}

		getKanbanEntries();
	};

	// Is called when the kanban entry has its arrows clicked on (TODO: Also when click and dragged around)
	const updateKanbanLane = async (lane: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			kanban.origin_type === 'group'
				? `group/${kanban.origin_id}/kanban/entry/update`
				: 'user/kanban/entry/update',
			{
				lane,
				entry_id: kanban.id
			}
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to update kanban lane',
				success: false
			});
			return;
		}

		kanban.lane = lane;
		await getKanbanEntries();
	};

	const editAssignee = (e: any) => {
		kanbanEdited.assignee_id = Number(e.target.value);
	};

	const handleChangePriority = (e: any) => {
		kanbanEdited.priority = Number(e.target.value);
	};

	const deleteKanbanEntry = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			kanban.origin_type === 'group'
				? `group/${kanban.origin_id}/kanban/entry/delete`
				: 'user/kanban/entry/delete',
			{ entry_id: kanban.id }
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to delete kanban task',
				success: false
			});
			return;
		}

		removeKanbanEntry(kanban.id);
	};

	const formatEndDate = async () => {
		const en = (await import('javascript-time-ago/locale/en')).default;
		endDate = new TimeAgo('en');
	};

	const cancelUpdateKanban = () => {
		initializeKanbanEdited();
		isEditing = false;
	};

	const getUsers = async () => {
		if (kanban.origin_type !== 'group' || !kanban.origin_id) {
			users = [];
			return;
		}

		const { res, json } = await fetchRequest(
			'GET',
			`group/${kanban.origin_id}/users?limit=${groupMembersLimit}`
		);

		if (res.ok) users = json?.results ?? [];
	};

	onMount(async () => {
		if (kanban.end_date !== null) await formatEndDate();
	});

	$: if (openModal && !isEditing)
		checkForLinks(kanban.description, `kanban-${kanban.id}-description`);

	$: if (openModal && kanban.id === selectedEntry) {
		initializeKanbanEdited();
	}

	$: if (isEditing) {
		images = kanban.attachments ?? [];
		getUsers();
	}
</script>

<svelte:window bind:innerWidth bind:outerWidth />

<div
	class="text-left bg-white dark:bg-darkobject dark:text-darkmodeText rounded-lg shadow-sm hover:shadow-md transition-shadow border border-gray-100 dark:border-gray-700 border-l-4 p-3 cursor-grab active:cursor-grabbing {isDragging ? 'opacity-50' : ''}"
	style="border-left-color: {priorityBorderColors[kanban.priority ?? 3]}"
	in:fade
	draggable="true"
	on:dragstart={(e) => {
		e.dataTransfer?.setData('text/plain', kanban.id.toString());
		if (e.dataTransfer) e.dataTransfer.effectAllowed = 'move';
		setTimeout(() => { isDragging = true; }, 0);
	}}
	on:dragend={() => { isDragging = false; }}
	on:click={() => {
		openModal = true;
		selectedEntry = kanban.id;
		initializeKanbanEdited();
	}}
	role="button"
	tabindex="0"
	on:keydown
>
	<div class="flex justify-between w-full items-start">
		<div
			class="text-primary dark:text-secondary text-left font-semibold pb-1 line-clamp-2"
		>
			{kanban.title}
		</div>

		<div class="cursor-pointer p-1">
			{#if kanban.priority}
				<KanbanIcons Class="text-sm" bind:priority={kanban.priority} />
			{/if}
		</div>
	</div>
	{#if kanban.end_date && endDate}
		<div class="text-sm text-gray-700 dark:text-darkmodeText">
			{new Intl.DateTimeFormat(navigator?.language, {
				weekday: 'short',
				day: '2-digit',
				month: 'long'
			})
				.format(new Date(kanban.end_date))
				.replace(/\b\w/g, (char) => char.toLowerCase())
				.replace(/^\w/, (c) => c.toUpperCase())}
		</div>
	{/if}
	<div
		class="mt-2 gap-2 items-center text-sm"
		on:click={() => {
			if (kanban.origin_type === 'group') goto(`/groups/${kanban.origin_id}`);
		}}
		role="button"
		tabindex="0"
		on:keydown
	>
		{#if kanban.origin_type === 'user'}
			<span
				class="hover:no-underline text-xs dark:text-gray-500 text-gray-400 italic"
			>
				{$userStore?.username}
			</span>
		{:else}
			<span
				class="hover:no-underline text-xs dark:text-gray-500 text-gray-400 italic"
				>{$_('Group')}: {$groupStore.find((g) => g.id === kanban.origin_id)
					?.name}</span
			>

			<span class="text-xs dark:text-gray-500 text-gray-400 italic">
				{#if kanban?.assignee}
					<ProfilePicture
						username={kanban.origin_type === 'group'
							? kanban?.assignee?.username
							: kanban.group_name}
						profilePicture={kanban?.assignee?.profile_image}
						Class=""
						size={1}
						displayName
					/>
				{/if}
			</span>
		{/if}
	</div>

	{#if kanban.work_group && kanban.work_group.name}
		<div class="text-xs dark:text-gray-500 text-gray-400 italic">
			{$_('Work Group')}: {elipsis(kanban.work_group.name || '', 20)}
		</div>
	{/if}
	<div
		class="flex justify-between items-center mt-2 pt-2 border-t border-gray-100 dark:border-gray-700"
	>
		<button
			class="p-2 md:p-1.5 rounded text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors disabled:opacity-30 disabled:cursor-not-allowed"
			disabled={kanban.lane <= 1}
			on:click={(event) => {
				event.stopPropagation();
				if (kanban.lane > 1) {
					updateKanbanLane(kanban.lane - 1);
				}
			}}
		>
			<Fa icon={faArrowLeft} size="sm" />
		</button>

		<button
			class="p-2 md:p-1.5 rounded text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors disabled:opacity-30 disabled:cursor-not-allowed"
			disabled={kanban.lane >= lanes.length - 1}
			on:click={(event) => {
				event.stopPropagation();
				if (kanban.lane < lanes.length - 1) {
					updateKanbanLane(kanban.lane + 1);
				}
			}}
		>
			<Fa icon={faArrowRight} size="sm" />
		</button>
	</div>
</div>

{#if kanban.id === selectedEntry}
	<Modal
		bind:open={openModal}
		id="kanban-entry-modal"
		Class="cursor-default min-w-[400px] max-w-[560px] z-50"
		buttons={isEditing
			? [
					{ label: 'Update', type: 'primary', onClick: updateKanbanEntry },
					{ label: 'Cancel', type: 'default', onClick: cancelUpdateKanban },
					{ label: 'Delete', type: 'warning', onClick: deleteKanbanEntry }
				]
			: [
					{ label: 'Edit', type: 'primary', onClick: () => (isEditing = true) },
					{
						label: 'Close',
						type: 'default',
						onClick: () => (openModal = false)
					}
				]}
	>
		<div slot="body">
			{#if isEditing}
				<div class="pb-2">
					<TextInput
						bind:value={kanbanEdited.title}
						required
						label="Title"
						id="kanban-edit-title"
					/>
				</div>
				<TextArea
					bind:value={kanbanEdited.description}
					label="Description"
					rows={5}
					Class="overflow-scroll"
					id="kanban-edit-description"
				/>

				<GroupSelection
					selectedGroupId={kanban.origin_id}
					bind:selectedWorkgroupId
					disableGroup
				/>

				<div class="text-left w-[300px]">
					<div class="block text-md pt-2">
						{$_('End date')}
					</div>
					<input
						type="datetime-local"
						bind:value={kanbanEdited.end_date}
						class="dark:text-darkmodeText w-full border rounded p-1 border-gray-300 dark:border-gray-600 dark:bg-darkobject
						   {kanbanEdited.end_date ? 'text-black' : 'text-gray-500'}"
						placeholder={$_('No end date set')}
					/>
				</div>
				<div class="text-left">
					<div class="block text-md pt-2">
						{$_('Priority')}
					</div>
					<Select
						Class="w-full"
						classInner="border bg-white border-gray-300 dark:border-gray-600 dark:bg-darkobject"
						labels={priorities.map((i) => priorityText[priorities.length - i])}
						values={priorities}
						bind:value={kanbanEdited.priority}
						onInput={handleChangePriority}
						innerLabel=""
					/>
				</div>
				<div class="flex gap-6 justify-between mt-2 flex-col">
					<div class="text-left">
						<div class="block text-md">
							{$_('Assignee')}
						</div>

						<Select
							Class="w-full"
							classInner="border bg-white border-gray-300 dark:border-gray-600 dark:bg-darkobject"
							labels={users.map((user) => user.user.username)}
							values={users.map((user) => user.user.id)}
							value={kanban?.assignee?.id || ''}
							onInput={editAssignee}
							innerLabel={$_('No assignee')}
							innerLabelOn={true}
						/>
					</div>
					<div class="text-left">
						<div class="block text-md">
							{$_('Attachments')}
						</div>
						<FileUploads bind:files={images} bind:toRemove disableCropping />
					</div>
				</div>
				<!-- View mode -->
			{:else}
				<!-- Colored header strip -->
				<div
					class="-mx-6 -mt-6 mb-5 px-6 pt-5 pb-4"
					style="border-top: 3px solid {laneColors[kanban.lane]}"
				>
					<div class="flex items-center gap-2 mb-2.5 flex-wrap">
						<span
							class="text-xs font-semibold px-2.5 py-1 rounded-full text-white"
							style="background-color: {laneColors[kanban.lane]}"
						>
							{lanes[kanban.lane]}
						</span>
						{#if kanban.priority}
							<span
								class="text-xs font-semibold px-2.5 py-1 rounded-full border flex items-center gap-1"
								style="color: {priorityBorderColors[kanban.priority]}; border-color: {priorityBorderColors[kanban.priority]}"
							>
								<PriorityIcons priority={kanban.priority} />
								{priorityText[priorities.length - kanban.priority]}
							</span>
						{/if}
					</div>
					<h2
						class="text-xl font-bold text-gray-900 dark:text-darkmodeText text-left leading-snug pr-8"
					>
						{kanban.title}
					</h2>
				</div>

				<!-- Description -->
				{#if kanban.description}
					<div class="mb-4 text-left">
						<p
							class="text-xs font-semibold uppercase tracking-wider text-gray-400 dark:text-gray-500 mb-1.5"
						>
							{$_('Description')}
						</p>
						<div
							id={`kanban-${kanban.id}-description`}
							class="text-sm text-gray-700 dark:text-gray-300 whitespace-pre-wrap leading-relaxed bg-gray-50 dark:bg-gray-800/50 rounded-lg p-3 max-h-[20vh] overflow-y-auto"
						>
							{kanban.description}
						</div>
					</div>
				{/if}

				<!-- Detail cards -->
				<div class="grid grid-cols-2 gap-2.5 mb-4">
					<div class="bg-gray-50 dark:bg-gray-800/50 rounded-lg p-3 text-left">
						<p
							class="text-xs font-semibold uppercase tracking-wider text-gray-400 dark:text-gray-500 mb-1 flex items-center gap-1"
						>
							<Fa icon={faCalendar} size="xs" />
							{$_('Due Date')}
						</p>
						{#if kanban.end_date}
							<p class="text-sm font-medium text-gray-800 dark:text-darkmodeText">
								{new Intl.DateTimeFormat(navigator?.language, {
									weekday: 'short',
									day: '2-digit',
									month: 'long'
								})
									.format(new Date(kanban.end_date))
									.replace(/\b\w/g, (char) => char.toLowerCase())
									.replace(/^\w/, (c) => c.toUpperCase())}
							</p>
						{:else}
							<p class="text-sm text-gray-400 italic">{$_('Not set')}</p>
						{/if}
					</div>

					<div class="bg-gray-50 dark:bg-gray-800/50 rounded-lg p-3 text-left">
						<p
							class="text-xs font-semibold uppercase tracking-wider text-gray-400 dark:text-gray-500 mb-1"
						>
							{$_('Assignee')}
						</p>
						{#if kanban.assignee}
							<div class="flex items-center gap-1.5 min-w-0">
								<ProfilePicture
									username={kanban.assignee.username}
									profilePicture={kanban.assignee.profile_image}
									size={1}
								/>
								<p
									class="text-sm font-medium text-gray-800 dark:text-darkmodeText truncate"
								>
									{kanban.assignee.username}
								</p>
							</div>
						{:else}
							<p class="text-sm text-gray-400 italic">{$_('Unassigned')}</p>
						{/if}
					</div>

					{#if kanban.origin_type === 'group'}
						<div class="bg-gray-50 dark:bg-gray-800/50 rounded-lg p-3 text-left">
							<p
								class="text-xs font-semibold uppercase tracking-wider text-gray-400 dark:text-gray-500 mb-1"
							>
								{$_('Group')}
							</p>
							<button
								class="text-sm font-medium text-primary hover:underline text-left truncate w-full"
								on:click={() => goto(`/groups/${kanban.origin_id}`)}
							>
								{$groupStore.find((g) => g.id === kanban.origin_id)?.name}
							</button>
						</div>

						<div class="bg-gray-50 dark:bg-gray-800/50 rounded-lg p-3 text-left">
							<p
								class="text-xs font-semibold uppercase tracking-wider text-gray-400 dark:text-gray-500 mb-1"
							>
								{$_('Work Group')}
							</p>
							<p class="text-sm font-medium text-gray-800 dark:text-darkmodeText">
								{kanban.work_group?.name ?? $_('None')}
							</p>
						</div>
					{/if}
				</div>

				<!-- Attachments -->
				{#if kanbanEdited.attachments && kanbanEdited.attachments.length > 0}
					<div class="text-left">
						<p
							class="text-xs font-semibold uppercase tracking-wider text-gray-400 dark:text-gray-500 mb-2"
						>
							{$_('Attachments')}
						</p>
						<div class="flex flex-wrap gap-2">
							{#each kanbanEdited.attachments as file}
								<a
									href={`${env.PUBLIC_API_URL}/media/${file.file}`}
									target="_blank"
									rel="noopener"
								>
									<img
										src={`${env.PUBLIC_API_URL}/media/${file.file}`}
										alt={file.file_name}
										class="w-16 h-16 rounded-lg object-cover border border-gray-200 dark:border-gray-700 hover:opacity-90 transition-opacity"
									/>
								</a>
							{/each}
						</div>
					</div>
				{/if}
			{/if}
		</div>
	</Modal>
{/if}

<style>
	.break {
		word-break: break-all;
	}
</style>

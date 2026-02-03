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
	import { faArrowLeft, faArrowRight } from '@fortawesome/free-solid-svg-icons';
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
	class="text-left bg-gray-50 dark:bg-darkobject dark:text-darkmodeText rounded shadow hover:bg-gray-200 dark:hover:brightness-125 p-2 border"
	in:fade
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
	<div class="flex justify-between mt-3">
		<button
			class="cursor-pointer py-0.5 transition-all"
			on:click={(event) => {
				event.stopPropagation();
				if (kanban.lane > 1) {
					updateKanbanLane(kanban.lane - 1);
				}
			}}
		>
			<Fa icon={faArrowLeft} size="md" />
		</button>

		<button
			class="cursor-pointer hover:dark:text-darkmodeText hover:text-gray-400 py-0.5 transition-all"
			on:click={(event) => {
				event.stopPropagation();
				if (kanban.lane < lanes.length - 1) {
					updateKanbanLane(kanban.lane + 1);
				}
			}}
		>
			<Fa icon={faArrowRight} size="md" />
		</button>
	</div>
</div>

{#if kanban.id === selectedEntry}
	<Modal
		bind:open={openModal}
		id="kanban-entry-modal"
		Class="cursor-default min-w-[400px] max-w-[500px] z-50"
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
				<!-- If not editing, so normal display -->
			{:else}
				<div class="text-center">
					<h2 class="pb-1 font-semibold text-xl w-full">{kanban.title}</h2>
				</div>
				<div class="flex mt-4 w-full">
					<div class="flex flex-col mr-4 text-left gap-1 w-full">
						{#if kanban.origin_type === 'group'}
							<p class="font-bold">{$_('Group')}</p>
							<p class="font-bold">{$_('Work Group')}</p>
						{/if}
						<p class="font-bold">{$_('End Date')}</p>
						<p class="font-bold">{$_('Priority')}</p>
						<p class="font-bold">{$_('Assignee')}</p>
						<p class="font-bold">{$_('Attachments')}</p>
					</div>

					<div class="flex flex-col text-right gap-1 w-full">
						<button
							class="text-right"
							on:click={() => goto(`/groups/${kanban?.origin_id}`)}
							>{$groupStore.find((g) => g.id === kanban.origin_id)
								?.name}</button
						>
						<p>{kanban?.work_group?.name ?? 'No Work Group'}</p>

						<p>
							{#if kanban?.end_date}
								{new Intl.DateTimeFormat(navigator?.language, {
									weekday: 'short',
									day: '2-digit',
									month: 'long'
								})
									.format(new Date(kanban.end_date))
									.replace(/\b\w/g, (char) => char.toLowerCase())
									.replace(/^\w/, (c) => c.toUpperCase())}
							{:else}
								{$_('No end date set')}
							{/if}
						</p>
						<div class="flex justify-end items-center gap-2 w-full">
							{#if kanban.priority}
								<PriorityIcons Class="ruby" priority={kanban?.priority} />
							{/if}
							<p>
								{kanbanEdited.priority != null
									? priorityText[priorities.length - kanbanEdited.priority]
									: $_('No priority')}
							</p>
						</div>
						<p>{kanban?.assignee?.username || $_('Unassigned')}</p>
						{#if kanbanEdited.attachments && kanbanEdited.attachments.length > 0}
							{#each kanbanEdited.attachments as file}
								<li>
									<img
										src={`${env.PUBLIC_API_URL}/media/${file.file}`}
										alt={file.file_name}
										class="w-10 h-10"
									/>
								</li>
							{/each}
						{:else}
							<p>{$_('No attachments available')}</p>
						{/if}
					</div>
				</div>
				<div class="text-left mt-1 w-full">
					<p class="font-bold">{$_('Description')}</p>
					<p
						class="max-h-[25vh] overflow-y-auto w-full id={`kanban-${kanban.id}-description`} whitespace-pre-wrap"
					>
						{kanban?.description}
					</p>
				</div>
			{/if}
		</div>
	</Modal>
{/if}

<style>
	.break {
		word-break: break-all;
	}
</style>

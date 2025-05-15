<script lang="ts">
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { fade } from 'svelte/transition';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { page } from '$app/stores';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
  import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import {
		checkForLinks,
		elipsis,
		getUserInfo,
		type StatusMessageInfo
	} from '$lib/Generic/GenericFunctions';
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

	export let kanban: kanban,
		type: 'group' | 'home',
		users: GroupUser[],
		removeKanbanEntry: (id: number) => void,
		changeNumberOfOpen: (addOrSub: 'Addition' | 'Subtraction') => void,
		workGroups: WorkGroup[] = [],
		getKanbanEntries: () => Promise<void>;

	const lanes = ['', 'Backlog', 'To do', 'In progress', 'Evaluation', 'Done'];

	let openModal = false,
		selectedEntry: number,
		status: StatusMessageInfo,
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
			images: kanban.attachments || []
		},
		endDate: TimeAgo;

	// Helper function to format date for datetime-local input
	function formatDateForInput(dateStr: string | null | undefined): string | null {
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
			images: kanban.attachments || []
		};
		console.log('Initialized kanbanEdited.end_date:', kanbanEdited.end_date);
	};

	$: console.log('Kanban end_date on modal open:', kanban.end_date);

	const updateKanbanContent = async () => {
		const formData = new FormData();

		formData.append('title', kanbanEdited.title);
		formData.append('tag', kanban.lane.toString());
		formData.append('lane', kanban.lane.toString());
		formData.append('entry_id', kanban.id.toString());
		formData.append('description', kanbanEdited.description || '');

		if (kanbanEdited.assignee_id)
			formData.append('assignee_id', kanbanEdited.assignee_id.toString());
		if (kanbanEdited.priority) formData.append('priority', kanbanEdited.priority.toString());

		if (kanbanEdited.work_group?.id)
			formData.append('work_group_id', kanbanEdited.work_group.id.toString());

		if (kanbanEdited.end_date) {
			const _endDate = new Date(kanbanEdited.end_date);
			const isoDate = _endDate.toISOString();
			const dateString = `${isoDate.slice(
				0,
				10
			)}T${_endDate.getHours()}:${_endDate.getMinutes()}`;
			formData.append('end_date', dateString);
		} else {
			formData.append('end_date', '');
		}

		const { res, json } = await fetchRequest(
			'POST',
			type === 'group'
				? `group/${
						env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' ? '1' : $page.params.groupId
				  }/kanban/entry/update`
				: 'user/kanban/entry/update',
			formData,
			true,
			false
		);

		console.log(res, json);

		isEditing = false;

		if (!res.ok) {
			status = { message: 'Failed to update kanban task', success: false };
			return;
		}

		kanban.title = kanbanEdited.title;
		kanban.description = kanbanEdited.description;
		kanban.priority = kanbanEdited.priority;
		kanban.end_date = kanbanEdited.end_date;
		kanban.work_group = kanbanEdited.work_group;
		kanban.attachments = kanbanEdited.images || [];

		const assignee = users.find((user) => user.user.id === kanbanEdited.assignee_id);
		kanban.assignee = kanbanEdited.assignee_id
			? {
					id: kanbanEdited.assignee_id,
					username: assignee?.user.username || '',
					profile_image: assignee?.user.profile_image || ''
			  }
			: null;

		await getKanbanEntries();
	};

	const updateKanbanLane = async (lane: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			kanban.origin_type === 'group'
				? `group/${
						env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' ? '1' : $page.params.groupId
				  }/kanban/entry/update`
				: 'user/kanban/entry/update',
			{
				lane,
				entry_id: kanban.id
			}
		);
		status = statusMessageFormatter(res, json);
		if (!res.ok) return;

		kanban.lane = lane;
		await getKanbanEntries();
	};

	const changeAssignee = (e: any) => {
		kanbanEdited.assignee_id = Number(e.target.value);
	};

	const handleChangePriority = (e: any) => {
		kanbanEdited.priority = Number(e.target.value);
		console.log('Selected priority:', kanbanEdited.priority);
	};

	const deleteKanbanEntry = async () => {
		if (kanban.origin_type === 'group' && !$page.params.groupId) {
			status = { message: 'Cannot remove kanban tasks from groups in My Kanban', success: false };
			return;
		}

		const { res, json } = await fetchRequest(
			'POST',
			kanban.origin_type === 'group'
				? `group/${$page.params.groupId}/kanban/entry/delete`
				: 'user/kanban/entry/delete',
			{ entry_id: kanban.id }
		);
		status = statusMessageFormatter(res, json);
		if (!res.ok) return;

		removeKanbanEntry(kanban.id);
	};

	const getGroupKanbanIsFrom = async () => {
		const { res, json } = await fetchRequest('GET', `group/${kanban.origin_id}/detail`);
		kanban.group_name = json.name;
	};

	const formatEndDate = async () => {
		const en = (await import('javascript-time-ago/locale/en')).default;
		endDate = new TimeAgo('en');
	};

	const handleChangeWorkGroup = (e: any) => {
		kanbanEdited.work_group =
			workGroups.find((group) => group.id === Number(e.target.value)) || null;
	};

	const cancelUpdateKanban = () => {
		initializeKanbanEdited();
		openModal = false;
		isEditing = false;
	};

	onMount(async () => {
		if (kanban?.origin_type === 'group') await getGroupKanbanIsFrom();
		if (kanban.end_date !== null) await formatEndDate();
	});

	$: if (openModal && !isEditing)
		checkForLinks(kanban.description, `kanban-${kanban.id}-description`);

	$: if (openModal === true) changeNumberOfOpen('Addition');
	else changeNumberOfOpen('Subtraction');

	$: if (openModal && kanban.id === selectedEntry) {
		initializeKanbanEdited();
	}
</script>

<svelte:window bind:innerWidth bind:outerWidth />

<button
	class="text-left bg-gray-50 dark:bg-darkobject dark:text-darkmodeText rounded shadow hover:bg-gray-200 dark:hover:brightness-125 p-2 border"
	in:fade
	on:click={() => {
		openModal = true;
		selectedEntry = kanban.id;
		initializeKanbanEdited();
	}}
>
	<div class="flex justify-between w-full items-start">
		<div
			class="text-primary dark:text-secondary text-left break-before-auto font-semibold break-all pb-1 line-clamp-2"
		>
			{kanban.title}
		</div>
		<div class="cursor-pointer hover:underline p-1">
			{#if kanban.priority}
				<KanbanIcons Class="text-sm" bind:priority={kanban.priority} />
			{/if}
		</div>
	</div>
	{#if kanban.end_date && endDate}
		<div class="text-sm text-gray-700">
			{new Intl.DateTimeFormat('sv-SE', {
				weekday: 'short',
				day: '2-digit',
				month: 'long'
			})
				.format(new Date(kanban.end_date))
				.replace(/\b\w/g, (char) => char.toUpperCase())}
		</div>
	{/if}
	<button
		class="mt-2 gap-2 items-center text-sm cursor-pointer hover:underline inline-flex"
		on:click={() => {
			if ($page.params.groupId) goto(`/user?id=${kanban?.assignee?.id}`);
			else if (kanban.origin_type === 'group') goto(`/groups/${kanban.origin_id}?page=kanban`);
		}}
	>
		{#if kanban.origin_type === 'user'}
			<ProfilePicture
				username={kanban.created_by.username}
				profilePicture={kanban.created_by.profile_image}
				Class=""
				size={1}
			/>
			{$_('My own')}
		{:else if kanban?.assignee}
			<ProfilePicture
				username={kanban?.assignee?.username}
				profilePicture={kanban?.assignee?.profile_image}
				Class=""
				size={1}
			/>

			<div class="break-all text-xs">
				{#if type === 'group'}
					{kanban.assignee?.username}
				{:else}
					{kanban.group_name}
				{/if}
			</div>
		{/if}
	</button>

	{#if kanban.work_group && kanban.work_group.name}
		<div class="text-sm">
			{$_('Work Group')}: {elipsis(kanban.work_group.name || '', 20)}
		</div>
	{/if}
	{#if (type === 'group' && kanban.origin_type === 'group') || (type === 'home' && kanban.origin_type === 'user')}
		<div class="flex justify-between mt-3 align-middle">
			<button
				class="cursor-pointer hover:text-gray-400 px-3 py-0.5 transition-all"
				on:click={() => {
					if (kanban.lane > 1) {
						updateKanbanLane(kanban.lane - 1);
					}
				}}
			>
				<Fa icon={faArrowLeft} size="sm" />
			</button>

			<button
				class="cursor-pointer hover:text-gray-400 px-3 py-0.5 transition-all"
				on:click={() => {
					if (kanban.lane < lanes.length - 1) {
						updateKanbanLane(kanban.lane + 1);
					}
				}}
			>
				<Fa icon={faArrowRight} size="sm" />
			</button>
		</div>
	{/if}
</button>

{#if kanban.id === selectedEntry}
	<Modal bind:open={openModal} Class=" min-w-[400px] z-50">
		<div slot="body">
			{#if isEditing}
				<StatusMessage bind:status disableSuccess />
				<div class="pb-2">
					<TextInput bind:value={kanbanEdited.title} required label="Title" />
				</div>
				<TextArea
					bind:value={kanbanEdited.description}
					label="Description"
					rows={5}
					Class="overflow-scroll"
				/>
				{#if type === 'group'}
					<div class="text-left">
						<div class="block text-md">
							{$_('Work Group')}
						</div>

						<Select
							Class="rounded border border-gray-300 dark:border-gray-600 dark:bg-darkobject"
							labels={workGroups.map((group) => elipsis(group.name))}
							values={workGroups.map((group) => group.id)}
							value={kanbanEdited.work_group?.id || ''}
							onInput={handleChangeWorkGroup}
							innerLabel={$_('No workgroup assigned')}
							innerLabelOn={true}
						/>
					</div>
				{/if}
				<div class="text-left w-[300px]">
					<div class="block text-md pt-2">
						{$_('End date')}
					</div>
					<input
						type="datetime-local"
						bind:value={kanbanEdited.end_date}
						class="w-full border rounded p-1 border-gray-300 dark:border-gray-600 dark:bg-darkobject
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
							onInput={changeAssignee}
							innerLabel={$_('No assignee')}
							innerLabelOn={true}
						/>
					</div>
					<div class="text-left">
						<div class="block text-md">
							{$_('Attachments')}
						</div>
						<!-- <FileUploads bind:images={kanbanEdited.images} /> -->
					</div>
				</div>
			{:else}
				<div class="text-center">
					<h2 class="pb-1 font-semibold break-words text-xl w-full">{kanban.title}</h2>
					{#if type === 'group'}
						<p class="w-full">{kanban?.work_group?.name || $_('No workgroup assigned')}</p>
					{/if}
				</div>
				<div class="flex mt-4 w-full">
					<div class="flex flex-col mr-4 text-left gap-1 w-full">
						<p class="font-bold">{$_('End Date')}</p>
						<p class="font-bold">{$_('Priority')}</p>
						<p class="font-bold">{$_('Assignee')}</p>
						<p class="font-bold">{$_('Attachments')}</p>
					</div>

					<div class="flex flex-col text-right gap-1 w-full">
						<p>
							{#if kanban?.end_date}
								{new Intl.DateTimeFormat('sv-SE', {
									weekday: 'short',
									day: '2-digit',
									month: 'long',
									year: 'numeric'
								})
									.format(new Date(kanban.end_date))
									.replace(/\b\w/g, (char) => char.toUpperCase())}
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
						{#if kanbanEdited.images && kanbanEdited.images.length > 0}
							{#each kanbanEdited.images as file}
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
						class="max-h-[25vh] overflow-y-auto break-words w-full id={`kanban-${kanban.id}-description`} whitespace-pre-wrap"
					>
						{kanban?.description}
					</p>
				</div>
			{/if}
		</div>
		<div slot="footer" class="w-full flex gap-4">
			{#if isEditing}
				<Button Class="w-full py-1" buttonStyle="primary-light" onClick={updateKanbanContent}
					>{$_('Update')}</Button
				>
				<Button
					Class="w-full bg-red-500  py-1"
					buttonStyle="warning-light"
					onClick={cancelUpdateKanban}>{$_('Cancel')}</Button
				>
			{:else}
				<Button Class="w-full py-1" buttonStyle="primary-light" onClick={() => (isEditing = true)}
					>{$_('Edit')}</Button
				>
				<Button
					Class="bg-red-500 w-full  py-1"
					buttonStyle="warning-light"
					onClick={deleteKanbanEntry}>{$_('Delete')}</Button
				>
			{/if}
		</div>
	</Modal>
{/if}
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
	import type { kanbanEdited, kanban as KanbanType } from './Kanban';
	import type { WorkGroup } from '../WorkingGroups/interface';
	import { env } from '$env/dynamic/public';
	import { faArrowLeft, faArrowRight } from '@fortawesome/free-solid-svg-icons';
	import Select from '$lib/Generic/Select.svelte';
	import { getContext } from 'svelte';

	export let kanban: KanbanType,
		type: 'group' | 'home',
		users: GroupUser[],
		removeKanbanEntry: (id: number) => void,
		changeNumberOfOpen = (addOrSub: 'Addition' | 'Subtraction') => {},
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
		// initializes the kanban to be edited when modal is opened
		kanbanEditedValue: kanbanEdited = {
			entry_id: kanban.id,
			description: kanban.description,
			title: kanban.title,
			assignee_id: kanban.assignee?.id,
			priority: kanban.priority,
			end_date: kanban.end_date ? new Date(kanban.end_date).toISOString().slice(0, 16) : null,
			work_group: kanban.work_group || null,
			//@ts-ignore
			images: kanban.attachments || []
		},
		endDate: TimeAgo;

	const updateKanbanContent = async () => {
  const formData = new FormData();

  formData.append('title', kanbanEditedValue.title);
  formData.append('tag', kanban.lane.toString());
  formData.append('lane', kanban.lane.toString());
  formData.append('entry_id', kanban.id.toString());
  formData.append('description', kanbanEditedValue.description || '');

  if (kanbanEditedValue.assignee_id !== undefined)
    formData.append('assignee_id', kanbanEditedValue.assignee_id?.toString() || '');
  if (kanbanEditedValue.priority !== undefined) 
    formData.append('priority', kanbanEditedValue.priority?.toString() || '');

  if (kanbanEditedValue.work_group?.id)
    formData.append('work_group_id', kanbanEditedValue.work_group.id.toString());

  if (kanbanEditedValue?.end_date) {
    const _endDate = new Date(kanbanEditedValue.end_date);
    const isoDate = _endDate?.toISOString();
    const dateString = `${isoDate?.slice(
      0,
      10
    )}T${_endDate?.getHours()}:${_endDate?.getMinutes()}`;
    if (_endDate) formData.append('end_date', dateString);
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

  isEditing = false;

  if (!res.ok) {
    status = { message: 'Failed to update kanban task', success: false };
    return;
  }

  kanban.title = kanbanEditedValue.title;
  kanban.description = kanbanEditedValue.description;
  
  kanban.priority = kanbanEditedValue.priority;

  if (kanbanEditedValue.images) kanban.attachments = kanbanEditedValue.images;
  else kanban.attachments = [];

  if (kanbanEditedValue.end_date !== null) kanban.end_date = kanbanEditedValue.end_date;
  else kanban.end_date = null;

  if (kanbanEditedValue.work_group !== null) {
    kanban.work_group = kanbanEditedValue.work_group;
  } else {
    kanban.work_group = undefined;
  }

  if (kanbanEditedValue.assignee_id !== undefined) {
    const assignee = users.find((user) => user.user.id === kanbanEditedValue.assignee_id);
    if (assignee && kanbanEditedValue.assignee_id) {
      kanban.assignee = {
        id: kanbanEditedValue.assignee_id,
        username: assignee?.user.username || '',
        profile_image: assignee?.user.profile_image || ''
      };
    } else if (kanbanEditedValue.assignee_id === null) {
      kanban.assignee = null;
    }
  }

  await getKanbanEntries();
  openModal = false;
}

	// Moves the kanban entry between the lanes
const updateKanbanLane = async (lane: number) => {
  const formData = new FormData();
  formData.append('lane', lane.toString());
  formData.append('entry_id', kanban.id.toString());
  
  if (kanban.priority !== undefined && kanban.priority !== null) {
    formData.append('priority', kanban.priority.toString());
  }
  
  const { res, json } = await fetchRequest(
    'POST',
    kanban.origin_type === 'group'
      ? `group/${
          env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' ? '1' : $page.params.groupId
        }/kanban/entry/update`
      : 'user/kanban/entry/update',
    formData,
    true,
    false
  );
  
  if (!res.ok) {
    status = { message: 'Failed to move task', success: false };
    return;
  }

  kanban.lane = lane;
  
  await getKanbanEntries();
}

	const changeAssignee = (e: any) => {
		kanbanEditedValue.assignee_id = Number(e.target.value);
	};

	const handleChangePriority = (e: any) => {
  kanbanEditedValue.priority = Number(e.target.value);
}

	// Delete kanban removes it from the database,
	// remove kanban removes the displaying of the kanban.
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
		// showSuccessPoppup = true;
	};

	//Whenever user is at own kanban, focus on which group it's on rather than on who is assigned (which is obviously the user looking at it)
	//Useful for the Users own personal kanban.
	const getGroupKanbanIsFrom = async () => {
		//TODO: detail is outdated
		const { res, json } = await fetchRequest('GET', `group/${kanban.origin_id}/detail`);
		kanban.group_name = json.name;
	};

	const formatEndDate = async () => {
		const en = (await import('javascript-time-ago/locale/en')).default;
		endDate = new TimeAgo('en');
	};

	const handleChangeWorkGroup = (e: any) => {
  const selectedId = Number(e.target.value);
  if (selectedId) {
    kanbanEditedValue.work_group = workGroups.find((group) => group.id === selectedId) || null;
  } else {
    kanbanEditedValue.work_group = null;
  }
}

	const cancelUpdateKanban = () => {
		(kanbanEditedValue = {
			entry_id: kanban.id,
			description: kanban.description,
			title: kanban.title,
			assignee_id: kanban.assignee?.id,
			priority: kanban.priority,
			end_date: kanban.end_date ? new Date(kanban.end_date).toISOString().slice(0, 16) : null,
			work_group: kanban.work_group || null,
			//@ts-ignore
			images: kanban.attachments || []
		}),
			(openModal = false);
		isEditing = false;
	};

	onMount(async () => {
		if (kanban?.origin_type === 'group') getGroupKanbanIsFrom();
		if (kanban.end_date !== null) formatEndDate();
	});

	$: if (openModal && !isEditing)
		checkForLinks(kanban.description, `kanban-${kanban.id}-description`);

	$: if (openModal === true) changeNumberOfOpen('Addition');
	else changeNumberOfOpen('Subtraction');

	$: openModal &&
		kanban.id !== selectedEntry &&
		(() => {
			kanbanEditedValue = {
				entry_id: kanban.id,
				description: kanban.description,
				title: kanban.title,
				assignee_id: kanban.assignee?.id,
				priority: kanban.priority,
				end_date: kanban.end_date ? new Date(kanban.end_date).toISOString().slice(0, 16) : null
			};
		})();
</script>

<svelte:window bind:innerWidth bind:outerWidth />

<button
	class="text-left bg-gray-50 dark:bg-darkobject dark:text-darkmodeText rounded shadow hover:bg-gray-200 dark:hover:brightness-125 p-2 border"
	in:fade
	on:click={() => {
		openModal = true;
		selectedEntry = kanban.id;
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
			<!-- {#if new Date(kanban.end_date) < new Date()}
				{$_('Ended')}
			{:else}
				{$_('Ends')}
			{/if} -->

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
	<!-- Arrows -->
	{#if (type === 'group' && kanban.origin_type === 'group') || (type === 'home' && kanban.origin_type === 'user')}
		<div class="flex justify-between mt-3 align-middle">
			<button
				class="cursor-pointer hover:text-gray-400 px-3 py-0.5 transition-all"
				on:click={() => {
					if (kanban.lane > 1) {
						updateKanbanLane(kanban.lane - 1);
						kanban.lane -= 1;
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
						kanban.lane += 1;
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
		<!-- <div slot="header">
			{#if isEditing}
				{$_('Edit Task')}
			{:else}
				{kanban.title}
			{/if}
		</div> -->

		<div slot="body">
			{#if isEditing}
				<StatusMessage bind:status disableSuccess />
				<div class="pb-2">
					<TextInput bind:value={kanbanEditedValue.title} required label="Title" />
				</div>
				<TextArea
					bind:value={kanbanEditedValue.description}
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
							value={kanbanEditedValue.work_group?.id || ''}
							onInput={handleChangeWorkGroup}
							innerLabel={$_('No workgroup assigned')}
							innerLabelOn={true}
						/>
					</div>
				{/if}
				<div class="text-left w-[300px]">
					<!-- {#if kanban.end_date} -->
					<div class="block text-md pt-2">
						{$_('End date')}
					</div>
					<input
						type="datetime-local"
						bind:value={kanbanEditedValue.end_date}
						class="w-full border rounded p-1 border-gray-300 dark:border-gray-600 dark:bg-darkobject
						   {kanbanEditedValue.end_date ? 'text-black' : 'text-gray-500'}"
					/>
					<!-- {/if} -->
				</div>
				<div class="text-left">
					<div class="block text-md pt-2">
						{$_('Priority')}
					</div>
					<Select
						Class="w-full"
						classInner="border bg-white border-gray-300 dark:border-gray-600 dark:bg-darkobject"
						labels={priorities.map((i) => priorityText[priorityText.length - i])}
						values={priorities}
						value={kanban?.priority}
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
								{kanbanEditedValue.priority != null
									? priorityText[priorityText.length - kanbanEditedValue.priority]
									: $_('No priority')}
							</p>
						</div>
						<!-- <p>{kanban?.assignee?.username || $_('Unassigned')}</p> -->
						{#if kanbanEditedValue.images && kanbanEditedValue.images.length > 0}
							{#each kanbanEditedValue.images as file}
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

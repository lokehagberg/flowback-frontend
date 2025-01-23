<script lang="ts">
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons/faArrowLeft';
	import { faArrowRight } from '@fortawesome/free-solid-svg-icons/faArrowRight';
	import { fade } from 'svelte/transition';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { page } from '$app/stores';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import { checkForLinks, elipsis, type StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import type { GroupUser } from '../interface';
	import { onMount } from 'svelte';
	import TimeAgo from 'javascript-time-ago';
	import KanbanIcons from './PriorityIcons.svelte';
	import PriorityIcons from './PriorityIcons.svelte';
	import { DateInput } from 'date-picker-svelte';
	import { goto } from '$app/navigation';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import type { kanbanEdited, kanban} from './Kanban';
	import FileUploads from '$lib/Generic/FileUploads.svelte';

	export let kanban: kanban,
		type: 'group' | 'home',
		users: GroupUser[],
		removeKanbanEntry: (id: number) => void,
		changeNumberOfOpen = (addOrSub: 'Addition' | 'Subtraction') => {};

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
		kanbanEdited : kanbanEdited = {
			entry_id: kanban.id,
			description: kanban.description,
			title: kanban.title,
			assignee: kanban.assignee?.id,
			priority: kanban.priority,
			end_date: kanban.end_date ? new Date(kanban.end_date) : null
		},
		endDate: TimeAgo;

	const updateKanbanContent = async () => {
		kanbanEdited.entry_id = kanban.id;
		//@ts-ignore
		// if (kanbanEdited.end_date === null) delete kanbanEdited.end_date;
		if (kanbanEdited.end_date === null) {
			delete kanbanEdited.end_date;
		} else if (kanbanEdited.end_date instanceof Date) {
			kanbanEdited.end_date = new Date(kanbanEdited.end_date.toISOString());
		}
		const { res, json } = await fetchRequest(
			'POST',
			kanban.origin_type === 'group'
				? `group/${$page.params.groupId}/kanban/entry/update`
				: 'user/kanban/entry/update',
			kanbanEdited
		);
		status = statusMessageFormatter(res, json);
		if (!res.ok) return;

		kanban.title = kanbanEdited.title;
		kanban.description = kanbanEdited.description;
		kanban.priority = kanbanEdited.priority;
		if (kanbanEdited.end_date !== null) {
			kanban.end_date = kanbanEdited.end_date?.toISOString();
		} else {
			kanban.end_date = null;
		}
		const assignee = users.find((user) => user.user.id === kanbanEdited.assignee);
		if (assignee && kanbanEdited?.assignee)
			kanban.assignee = {
				id: kanbanEdited?.assignee,
				username: assignee?.user.username || '',
				profile_image: assignee?.user.profile_image || ''
			};

		isEditing = false;
	};

	const updateKanbanLane = async (lane: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			kanban.origin_type === 'group'
				? `group/${$page.params.groupId}/kanban/entry/update`
				: 'user/kanban/entry/update',
			{
				lane,
				entry_id: kanban.id
			}
		);
		status = statusMessageFormatter(res, json);
		if (!res.ok) return;

		kanban.lane = kanban.lane;
	};

	const changeAssignee = (e: any) => {
		kanbanEdited.assignee = Number(e.target.value);
	};

	const handleChangePriority = (e: any) => {
		kanbanEdited.priority = Number(e.target.value);
	};

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
			kanbanEdited = {
				entry_id: kanban.id,
				description: kanban.description,
				title: kanban.title,
				assignee: kanban.assignee?.id,
				priority: kanban.priority,
				end_date: kanban.end_date ? new Date(kanban.end_date) : null
			};
		})();
</script>

<svelte:window bind:innerWidth bind:outerWidth />

<button
	class="text-left bg-gray-50 dark:bg-darkobject dark:text-darkmodeText rounded shadow hover:bg-gray-200 dark:hover:brightness-125 p-2"
	in:fade
	on:click={() => {
		openModal = true;
		selectedEntry = kanban.id;
	}}
>
	{#if kanban.end_date && endDate}
		<div class="text-sm">
			{#if new Date(kanban.end_date) < new Date()}
				{$_('Ended')}
			{:else}
				{$_('Ends')}
			{/if}
			{endDate.format(new Date(kanban.end_date))}
		</div>
	{/if}
	<div class="flex justify-between w-full items-start">
		<div class="text-primary text-left break-before-auto font-semibold">{kanban.title}</div>
		<div class="cursor-pointer hover:underline">
			{#if kanban.priority}
				<KanbanIcons bind:priority={kanban.priority} />
			{/if}
		</div>
	</div>
	<button
		class="mt-2 gap-2 items-center text-sm cursor-pointer hover:underline inline-flex"
		on:click={() => {
			if ($page.params.groupId) goto(`/user?id=${kanban.assignee.id}`);
			else if (kanban.origin_type === 'group') goto(`/groups/${kanban.origin_id}?page=kanban`);
		}}
	>
		{#if kanban?.assignee}
			<ProfilePicture
				username={kanban?.assignee?.username}
				profilePicture={kanban?.assignee?.profile_image}
				Class=""
				size={20}
			/>

			<div class="break-all text-xs">
				{#if type === 'group'}
					{kanban.assignee?.username}
				{:else if kanban.origin_type === 'user'}
					{$_('My own')}
				{:else}
					{kanban.group_name}
				{/if}
			</div>
		{/if}
	</button>

	{#if kanban.work_group}
		<div>
			{$_('Work Group')}: {elipsis(kanban.work_group.name, 20)}
		</div>
	{/if}
	<!-- Arrows -->
	{#if (type === 'group' && kanban.origin_type === 'group') || (type === 'home' && kanban.origin_type === 'user')}
		<div class="flex justify-between mt-3 align-middle">
			<button
				class="cursor-pointer hover:text-gray-500 py-1"
				on:click={() => {
					if (kanban.lane > 1) {
						updateKanbanLane(kanban.lane - 1);
						kanban.lane -= 1;
					}
				}}
			>
				<Fa icon={faArrowLeft} size="1x" />
			</button>

			<button
				class="cursor-pointer hover:text-gray-500 py-1"
				on:click={() => {
					if (kanban.lane < lanes.length - 1) {
						updateKanbanLane(kanban.lane + 1);
						kanban.lane += 1;
					}
				}}
			>
				<Fa icon={faArrowRight} size="1x" />
			</button>
		</div>
	{/if}
</button>

{#if kanban.id === selectedEntry}
	<Modal bind:open={openModal} Class="min-w-[400px] z-50 break-words">
		<div slot="header">
			{#if isEditing}
				{$_('Edit Task')}
			{:else}
				{kanban.title}
			{/if}
		</div>

		<div slot="body">
			{#if isEditing}
				<StatusMessage bind:status disableSuccess />
				<TextInput bind:value={kanbanEdited.title} required label="Title" inputClass="border-none" />
				<TextArea bind:value={kanbanEdited.description} label="Description" rows={5}/>
				<div class="flex gap-6 justify-between mt-2 flex-col">
					<div class="text-left">
						{$_('Assignee')}
						<select
							on:input={changeAssignee}
							value={kanban?.assignee?.id}
							class="rounded-sm p-1 border bg-white border-gray-300 dark:border-gray-600 dark:bg-darkobject"
						>
							{#each users as user}
								<option value={user.user.id}>{user.user.username}</option>
							{/each}
						</select>
					</div>
					<div class="text-left">
						{$_('Priority')}
						<select
							class="rounded-sm p-1 border bg-white border-gray-300 dark:border-gray-600 dark:bg-darkobject"
							on:input={handleChangePriority}
							value={kanban?.priority}
						>
							{#each priorities as i}
								<option value={i}>{priorityText[priorityText.length - i]} </option>
							{/each}
						</select>
					</div>
					<div class="text-left w-[300px]">
						<!-- {#if kanban.end_date} -->
						{$_('End Date')}
						<DateInput bind:value={kanbanEdited.end_date} min={new Date()} />
						<!-- {/if} -->
					</div>
					<div class="text-left">
						{$_('Attachments')}
						<FileUploads bind:images={kanbanEdited.images} />
					</div>
				</div>
			{:else}
				<div class="max-h-[40vh] text-left" id={`kanban-${kanban.id}-description`}>
					{kanban?.description}
				</div>
				<div class="mt-6 text-left">
					<span>
						{$_('End Date')}: {kanban?.end_date ? new Date(kanban.end_date).toISOString().split('T')[0] : $_('No end date set')}
					</span>
				</div>
				<div class="text-left">
					<span>
						{$_('Assignee')}: {kanban?.assignee?.username || $_('Unassigned')}
					</span>
				</div>
				<div class="text-left">
					<span>
						{$_('Work Group')}: {kanban?.work_group?.name || $_('Unassigned')}
					</span>
					<div class="flex gap-2 align-middle">
						<span>{$_('Priority')}: {kanbanEdited.priority != null ? priorityText[priorityText.length - kanbanEdited.priority] : $_('No priority')}</span>
						{#if kanban.priority}
							<PriorityIcons Class="ruby" priority={kanban?.priority} />
						{/if}
					</div>
				</div>
				<div class="text-left">					
					{#if kanbanEdited.images && kanbanEdited.images.length > 0}
						{$_('Attachments:')}
						{#each kanbanEdited.images as file}
							<li>
								<span>{file.name}</span>
							</li>
						{/each}
					{:else}
						<p>{$_('No attachments available.')}</p>
					{/if}
				</div>
			{/if}
		</div>
		<div slot="footer">
			{#if isEditing}
				<Button action={updateKanbanContent}>{$_('Update')}</Button>
				<Button action={deleteKanbanEntry} Class="bg-red-500">{$_('Delete')}</Button>
			{:else}
				<Button Class="px-2" action={() => (isEditing = true)}>{$_('Edit')}</Button>
			{/if}
		</div>
	</Modal>
{/if}

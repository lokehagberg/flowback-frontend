<script lang="ts">
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
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
	import { checkForLinks, type StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import type { GroupUser, kanban } from '../interface';
	import { onMount } from 'svelte';
	import TimeAgo from 'javascript-time-ago';
	import KanbanIcons from './PriorityIcons.svelte';
	import PriorityIcons from './PriorityIcons.svelte';
	import { DateInput } from 'date-picker-svelte';
	import { goto } from '$app/navigation';

	export let kanban: kanban,
		type: 'group' | 'home',
		users: GroupUser[],
		removeKanbanEntry: (id: number) => void,
		changeNumberOfOpen = (addOrSub: 'Addition' | 'Subtraction') => {};

	const tags = ['', 'Backlog', 'To do', 'In progress', 'Evaluation', 'Done'];

	let openModal = false,
		selectedEntry: number,
		status: StatusMessageInfo,
		priorities = [5, 4, 3, 2, 1],
		priorityText = [
			'Very high priority',
			'High priority',
			'Medium priority',
			'Low priority',
			'Very low priority'
		],
		isEditing = false,
		innerWidth: number,
		outerWidth: number,
		// initializes the kanban to be edited when modal is opened
		kanbanEdited = {
			entry_id: kanban.id,
			id: kanban.id,
			description: kanban.description,
			title: kanban.title,
			assignee: kanban.assignee?.id,
			priority: kanban.priority,
			end_date: kanban.end_date ? new Date(kanban.end_date) : null
		};

	$: if (openModal === true) changeNumberOfOpen('Addition');
	else changeNumberOfOpen('Subtraction');

	$: openModal &&
		kanban.id !== selectedEntry &&
		(() => {
			kanbanEdited = {
				entry_id: kanban.id,
				id: kanban.id,
				description: kanban.description,
				title: kanban.title,
				assignee: kanban.assignee?.id,
				priority: kanban.priority,
				end_date: kanban.end_date ? new Date(kanban.end_date) : null
			};
		})();

	const updateKanbanContent = async () => {
		kanbanEdited.entry_id = kanban.id;
		//@ts-ignore
		if (kanbanEdited.end_date === null) delete kanbanEdited.end_date;

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

		const assignee = users.find((user) => user.user.id === kanbanEdited.assignee);
		kanban.assignee = {
			id: kanbanEdited?.assignee,
			username: assignee?.user.username || '',
			profile_image: assignee?.user.profile_image || ''
		};

		// showSuccessPoppup = true;

		isEditing = false;
	};

	const updateKanbanTag = async (tag: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			kanban.origin_type === 'group'
				? `group/${$page.params.groupId}/kanban/entry/update`
				: 'user/kanban/entry/update',
			{
				tag,
				entry_id: kanban.id
			}
		);
		status = statusMessageFormatter(res, json);
		if (!res.ok) return;

		kanban.tag = kanban.tag;
		// showSuccessPoppup = true;
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
	const getGroupKanbanIsFrom = async () => {
		//TODO: detail is outdated
		const { res, json } = await fetchRequest('GET', `group/${kanban.origin_id}/detail`);
		kanban.group_name = json.name;
	};

	let endDate: TimeAgo;
	const formatEndDate = async () => {
		const en = (await import('javascript-time-ago/locale/en')).default;
		// TimeAgo.addDefaultLocale(en);
		endDate = new TimeAgo('en');
	};

	onMount(async () => {
		if (kanban?.origin_type === 'group') getGroupKanbanIsFrom();
		if (kanban.end_date !== null) formatEndDate();
	});

	$: if (openModal && !isEditing)
		checkForLinks(kanban.description, `kanban-${kanban.id}-description`);
</script>

<!-- {@debug showSuccessPoppup} -->
<!-- <SuccessPoppup bind:show={showSuccessPoppup} /> -->
<svelte:window bind:innerWidth bind:outerWidth />

{#if (kanban.origin_type === 'group' && kanban.group_name) || kanban.origin_type === 'user'}
	<li
		class="bg-gray-100 dark:bg-darkobject dark:text-darkmodeText rounded border border-gray-400 hover:bg-gray-200 dark:hover:brightness-125 p-2"
		in:fade
	>
		{#if kanban.end_date !== null && endDate}
			<div class="text-sm">
				Ends {endDate.format(new Date(kanban.end_date))}
			</div>
		{/if}
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<div
			on:click={() => {
				openModal = true;
				selectedEntry = kanban.id;
			}}
			class="cursor-pointer hover:underline"
			on:keydown
		>
			<div class="p-1 py-3">{kanban.title}</div>
		</div>
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<div
			class="mt-2 gap-2 items-center text-sm cursor-pointer hover:underline inline-flex"
			on:click={() => {
				if ($page.params.groupId) goto(`/user?id=${kanban.assignee.id}`);
				else if (kanban.origin_type === 'group') goto(`/groups/${kanban.origin_id}?page=kanban`);
			}}
			on:keydown
		>
			<ProfilePicture
				username={kanban.assignee.username}
				profilePicture={kanban.assignee.profile_image}
				Class=""
			/>
			<div class="break-all text-xs">
				{#if type === 'group'}
					{kanban.assignee?.username}
				{:else if kanban.origin_type === 'user'}
					My own
				{:else}
					{kanban.group_name}
				{/if}
			</div>
		</div>
		<!-- Arrows -->
		{#if (type === 'group' && kanban.origin_type === 'group') || (type === 'home' && kanban.origin_type === 'user')}
			<div class="flex justify-between mt-3 align-middle">
				<div
					class="cursor-pointer hover:text-gray-500 py-1"
					on:click={() => {
						if (kanban.tag > 1) {
							updateKanbanTag(kanban.tag - 1);
							kanban.tag -= 1;
						}
					}}
					on:keydown
					tabindex="0"
					role="button"
				>
					<Fa icon={faArrowLeft} size="1x" />
				</div>

				<KanbanIcons bind:priority={kanban.priority} />

				<div
					class="cursor-pointer hover:text-gray-500 py-1"
					on:click={() => {
						if (kanban.tag < tags.length - 1) {
							updateKanbanTag(kanban.tag + 1);
							kanban.tag += 1;
						}
					}}
					on:keydown
					tabindex="0"
					role="button"
				>
					<Fa icon={faArrowRight} size="1x" />
				</div>
			</div>
		{/if}
	</li>
{/if}

{#if kanban.id === selectedEntry}
	<Modal bind:open={openModal} Class="min-w-[400px] z-50 break-words">
		<div slot="header" class="">
			{#if isEditing}
				<TextInput bind:value={kanbanEdited.title} label="" inputClass="border-none" />
			{:else}
				{kanban.title}
			{/if}
		</div>

		<div slot="body">
			{#if isEditing}
				<StatusMessage bind:status disableSuccess />
				<!-- <TextArea
					rows={10}
					bind:value={kanbanEdited.description}
					label=""
					Class="h-full"
					inputClass="border-none"
				/> -->
				<div class="flex gap-6 justify-between mt-2 flex-col">
					<div class="text-left">
						Assignee
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
						End Date
						<DateInput bind:value={kanbanEdited.end_date} min={new Date()} />
						<!-- {/if} -->
					</div>
				</div>
			{:else}
				<div class="max-h-[40vh] text-left" id={`kanban-${kanban.id}-description`}>
					{kanban?.description}
				</div>
				<div class="mt-6 text-left">
					<span>
						Assignee: {kanban?.assignee?.username}
					</span>
					<div class="flex gap-2 align-middle">
						<span>Priority:</span>
						<PriorityIcons Class="ruby" priority={kanban?.priority} />
					</div>
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

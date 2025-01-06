<script lang="ts">
	import { _ } from 'svelte-i18n';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { DateInput } from 'date-picker-svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { page } from '$app/stores';
	import Modal from '$lib/Generic/Modal.svelte';
	import FileUploads from '$lib/Generic/FileUploads.svelte';
	import type { GroupUser, kanban } from '../interface';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { poppup } from '$lib/Generic/Poppup';
	import type { WorkGroup } from '../WorkingGroups/interface';
	import { elipsis } from '$lib/Generic/GenericFunctions';

	//TODO: the interfaces "kanban" and "KanbanEntry" are equivalent, make them use the same interface.
	let description = '',
		title = '',
		assignee: number | null = null,
		priorities = [5, 4, 3, 2, 1],
		priorityText = [
			'Very high priority',
			'High priority',
			'Medium priority',
			'Low priority',
			'Very low priority'
		],
		priority: undefined | number = 3,
		end_date: null | Date = null,
		loading = false,
		poppup: poppup,
		images: File[],
		workGroup: WorkGroup | null = null;

	export let type: 'home' | 'group',
		open: boolean = false,
		users: GroupUser[] = [],
		kanbanEntries: kanban[],
		workGroups: WorkGroup[] = [],
		lane: number = 1;

	const createKanbanEntry = async () => {
		loading = true;
		const isoDate = end_date?.toISOString();
		const dateString = `${isoDate?.slice(0, 10)}T${end_date?.getHours()}:${end_date?.getMinutes()}`;
		const formData = new FormData();

		formData.append('title', title);
		formData.append('tag', lane.toString());
		formData.append('lane', lane.toString());

		if (assignee) formData.append('assignee', assignee.toString());
		if (end_date) formData.append('end_date', dateString);
		if (priority) formData.append('priority', priority.toString());
		if (workGroup) formData.append('work_group_id', workGroup.id.toString());

		description = description.trim() === '' ? $_('No description provided') : description;
		formData.append('description', description);
		// if (description !== '') formData.append('description', description);
		if (images)
			images.forEach((image) => {
				formData.append('attachments', image);
			});

		const { res, json } = await fetchRequest(
			'POST',
			type === 'group'
				? `group/${$page.params.groupId}/kanban/entry/create`
				: 'user/kanban/entry/create',
			formData,
			true,
			false
		);

		loading = false;

		if (!res.ok) {
			poppup = { message: 'Failed to create kanban task', success: false };
			return;
		}

		poppup = { message: 'Successfully created kanban task', success: true };

		const userAssigned = users.find((user) => assignee === user.user.id);
		kanbanEntries.push({
			assignee: {
				id: assignee || 0,
				profile_image: userAssigned?.user.profile_image || '',
				username: userAssigned?.user.username || $_('Unassigned')
			},
			group: { id: 0, image: '', name: '' },
			description,
			lane,
			title,
			work_group: { id: workGroup?.id || 0, name: workGroup?.name || '' },
			id: json,
			created_by: 1,
			origin_id: 1,
			origin_type: type === 'group' ? 'group' : 'user',
			group_name: '',
			priority,
			end_date: end_date?.toString() || null
		});

		kanbanEntries = kanbanEntries;
		open = false;

		description = '';
		title = '';
		priority = 3;
		end_date = null;
	};

	const handleChangeAssignee = (e: any) => {
		assignee = Number(e.target.value);
	};

	const handleChangePriority = (e: any) => {
		priority = Number(e.target.value);
	};

	const handleChangeWorkGroup = (e: any) => {
		workGroup = workGroups.find((group) => group.id === Number(e.target.value)) || null;
	};
</script>

<!-- Creating a new Kanban or Editing a new Kanban -->
<Modal bind:open onSubmit={createKanbanEntry}>
	<div slot="header">{$_('Create Task')}</div>
	<div slot="body">
		<Loader bind:loading>
			<div on:submit|preventDefault={createKanbanEntry} class="mt-2">
				<TextInput required label="Title" placeholder="Title" bind:value={title} />
				<TextArea label="Description" bind:value={description} />
				<div class="flex gap-6 justify-between mt-2 flex-col">
					{#if type === 'group'}
						<div class="text-left">
							{$_('Assignee')}
							<select
								on:input={handleChangeAssignee}
								class="rounded-sm p-1 border border-gray-300 dark:border-gray-600 dark:bg-darkobject"
							>
								<option value={null}>{$_('Select')}</option>
								{#each users as user}
									<option value={user.user.id}>{user.user.username}</option>
								{/each}
							</select>
						</div>
					{/if}
					<div class="text-left">
						{$_('Priority')}
						<select
							class="rounded-sm p-1 border border-gray-300 dark:border-gray-600 dark:bg-darkobject"
							on:input={handleChangePriority}
							value={priority}
						>
							{#each priorities as i}
								<option value={i}>
									{$_(priorityText[priorityText.length - i])}
								</option>
							{/each}
						</select>
					</div>
					{#if type === 'group'}
						<div class="text-left">
							{$_('Work Group')}
							<select
								style="width:100%"
								class=" rounded-sm p-1 border border-gray-300 dark:border-gray-600 dark:bg-darkobject"
								on:input={handleChangeWorkGroup}
							>
								{#each workGroups as group}
									<option class="w-5" value={group.id}>
										{elipsis(group.name)}
									</option>
								{/each}
							</select>
						</div>
					{/if}
					<div class="text-left">
						{$_('End date')}
						<DateInput bind:value={end_date} min={new Date()} />
					</div>
				</div>
				<FileUploads bind:images />
			</div>
		</Loader>
	</div>
	<div slot="footer">
		<Button Class="" type="submit">{$_('Create task')}</Button>
	</div>
</Modal>

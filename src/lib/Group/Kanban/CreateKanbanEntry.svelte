<script lang="ts">
	import { _ } from 'svelte-i18n';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import FileUploads from '$lib/Generic/FileUploads.svelte';
	import type { GroupUser } from '../interface';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { poppup } from '$lib/Generic/Poppup';
	import type { WorkGroup } from '../WorkingGroups/interface';
	import { elipsis } from '$lib/Generic/GenericFunctions';
	import type { kanban } from './Kanban';

	export let type: 'home' | 'group',
		open: boolean = false,
		users: GroupUser[] = [],
		kanbanEntries: kanban[],
		workGroups: WorkGroup[] = [],
		lane: number = 1,
		groupId;

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
		end_date: null | string = null,
		loading = false,
		poppup: poppup,
		images: File[],
		workGroup: WorkGroup | null = null;

	const createKanbanEntry = async () => {
		loading = true;

		const formData = new FormData();

		if (end_date) {
			const _endDate = new Date(end_date || '');
			const isoDate = _endDate?.toISOString();
			const dateString = `${isoDate?.slice(
				0,
				10
			)}T${_endDate?.getHours()}:${_endDate?.getMinutes()}`;
			if (_endDate) formData.append('end_date', dateString);
		}

		formData.append('title', title);
		formData.append('tag', lane.toString());
		formData.append('lane', lane.toString());

		if (assignee) formData.append('assignee_id', assignee.toString());
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
			type === 'group' ? `group/${groupId}/kanban/entry/create` : 'user/kanban/entry/create',
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
			id: json,
			created_by: 1,
			origin_id: 1,
			origin_type: type === 'group' ? 'group' : 'user',
			group_name: '',
			priority,
			end_date: end_date?.toString() || null,
			//@ts-ignore
			work_group: { id: workGroup?.id, name: workGroup?.name } || null,
			attachments: []
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
<Modal bind:open Class="min-w-[400px] max-w-[500px]" onSubmit={createKanbanEntry}>
	<!-- <div slot="header">{$_('Create Task')}</div> -->
	<div slot="body">
		<Loader bind:loading>
			<div on:submit|preventDefault={createKanbanEntry}>
				<div class="pb-2">
					<TextInput Class="text-md" required label="Title" bind:value={title} />
				</div>
				<TextArea Class="text-md" inputClass="whitespace-pre-wrap" label="Description" bind:value={description} />
				{#if type === 'group'}
					<div class="text-left">
						<label class="block text-md" for="work-group">
							{$_('Work Group')}
						</label>
						<select
							style="width:100%"
							class="rounded p-1 border border-gray-300 dark:border-gray-600 dark:bg-darkobject text-gray-500"
							on:input={handleChangeWorkGroup}
							id="work-group"
						>
							<option class="w-5" value={null}> {$_('Select')} </option>

							{#each workGroups as group}
								<option class="w-5 text-black" value={group.id}>
									{elipsis(group.name)}
								</option>
							{/each}
						</select>
					</div>
				{/if}
				<div class="text-left">
					<label class="block text-md pt-2" for="end_date">
						{$_('End date')}
					</label>
					<input
						bind:value={end_date}
						class="w-full border rounded p-1 border-gray-300 dark:border-gray-600 dark:bg-darkobject
						   {end_date ? 'text-black' : 'text-gray-500'}"
						type="datetime-local"
						id="end_date"
					/>
				</div>
				<div class="text-left">
					<label for="handleChangePriority" class="block text-md pt-2">
						{$_('Priority')}
					</label>
					<select
						class="w-full rounded p-1 border border-gray-300 dark:border-gray-600 dark:bg-darkobject"
						on:input={handleChangePriority}
						value={priority}
						id="handleChangePriority"
					>
						{#each priorities as i}
							<option value={i}>
								{$_(priorityText[priorityText.length - i])}
							</option>
						{/each}
					</select>
					<div class="flex gap-6 justify-between mt-2 flex-col" />
					{#if type === 'group'}
						<div class="text-left">
							<label class="block text-md" for="handle-change-assignee">
								{$_('Assignee')}
							</label>
							<select
								on:input={handleChangeAssignee}
								class="w-full rounded p-1 border border-gray-300 text-gray-500 dark:border-gray-600 dark:bg-darkobject"
								id="handle-change-assignee"
							>
								<option value={null}>{$_('Select')}</option>
								{#each users as user}
									<option class="text-black" value={user.user.id}>{user.user.username}</option>
								{/each}
							</select>
						</div>
					{/if}
					<div class="text-left">
						<label class="block text-md">
							{$_('Attachments')}
						</label>
						<FileUploads bind:files={images} />
					</div>
				</div>
			</div>
		</Loader>
	</div>

	<div slot="footer" class="flex justify-between gap-4 mx-6 mb-2">
		<Button Class="w-full py-1" buttonStyle="primary-light" type="submit">{$_('Confirm')}</Button>
		<Button Class="w-full py-1" buttonStyle="warning-light" onClick={() => (open = false)}
			>{$_('kanbanEntry.Cancel', { default: 'Cancel' })}</Button
		>
	</div>
</Modal>

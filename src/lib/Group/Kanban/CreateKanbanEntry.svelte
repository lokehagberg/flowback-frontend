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
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { poppup } from '$lib/Generic/Poppup';

	const tags = ['', 'Backlog', 'To do', 'Current', 'Evaluation', 'Done'];
	//TODO: the interfaces "kanban" and "KanbanEntry" are equivalent, make them use the same interface.
	let description = '',
		title = '',
		assignee: number | null = null,
		users: GroupUser[] = [],
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
		workGroup: any = [],
		workingGroups: any = [];

	export let type: 'home' | 'group',
		open: boolean = false,
		kanbanEntries: kanban[] = [];

	const createKanbanEntry = async () => {
		loading = true;
		const dateString = `${end_date?.getFullYear()}-${end_date?.getMonth()}-${end_date?.getDate()}T${end_date?.getHours()}:${end_date?.getMinutes()}`;

		const formData = new FormData();
		formData.append('tag', '1');
		formData.append('title', title);
		if (assignee) formData.append('assignee', assignee.toString());
		if (priority) formData.append('priority', priority.toString());
		if (end_date) formData.append('end_date', dateString);
		if (description !== '') formData.append('description', description);
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
		if (!assignee) return;
		kanbanEntries.push({
			assignee: {
				id: assignee,
				profile_image: userAssigned?.user.profile_image || '',
				username: userAssigned?.user.username || 'unasigned'
			},
			group: { id: 0, image: '', name: '' },
			description,
			tag: 1,
			title,
			id: json,
			created_by: 1,
			origin_id: 1,
			origin_type: type === 'group' ? 'group' : 'user',
			group_name: '',
			priority,
			end_date: end_date?.toString() || null
		});

		kanbanEntries = kanbanEntries;

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

	const handleChangWorkGroup = (e: any) => {
		Number(e.target.value);
	};
</script>

<!-- Creating a new Kanban or Editing a new Kanban -->
<Modal bind:open Class="!overflow-visible" onSubmit={createKanbanEntry}>
	<div slot="header">{$_('Create Task')}</div>
	<div slot="body">
		<Loader bind:loading>
			<div on:submit|preventDefault={createKanbanEntry} class="mt-2">
				<TextInput required label="Title" bind:value={title} />
				<TextArea label="Description" bind:value={description} />
				<div class="flex gap-6 justify-between mt-2 flex-col">
					{#if type === 'group'}
						<div class="text-left">
							{$_('Assignee')}
							<select
								on:input={handleChangeAssignee}
								class="rounded-sm p-1 border border-gray-300 dark:border-gray-600 dark:bg-darkobject"
							>
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
									{priorityText[priorityText.length - i]}
								</option>
							{/each}
						</select>
					</div>
					<div class="text-left">
						{$_('Work group')}
						<select
							class="rounded-sm p-1 border border-gray-300 dark:border-gray-600 dark:bg-darkobject"
							on:input={handleChangWorkGroup}
							value={workGroup}
						>
							{#each workingGroups as group}
								<option value={group}>
									{group.name}
								</option>
							{/each}
						</select>
					</div>
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

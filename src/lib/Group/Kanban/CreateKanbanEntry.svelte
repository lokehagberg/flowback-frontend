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
	import Select from '$lib/Generic/Select.svelte';
	import { onMount } from 'svelte';

	export let type: 'home' | 'group',
		open: boolean = false,
		users: GroupUser[] = [],
		kanbanEntries: kanban[],
		workGroups: WorkGroup[] = [],
		lane: number = 1,
		groupId: string,
		getKanbanEntries: () => Promise<void>;

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
		priority: number | undefined = 3,
		end_date: string | null = new Date().toISOString().slice(0, 16),
		loading = false,
		poppup: poppup,
		images: File[] = [],
		workGroup: number | undefined;

	const createKanbanEntry = async () => {
		loading = true;

		const formData = new FormData();

		formData.append('title', title);
		formData.append('tag', lane.toString());
		formData.append('lane', lane.toString());
		if (assignee) formData.append('assignee_id', assignee.toString());
		if (priority) formData.append('priority', priority.toString());
		if (workGroup) formData.append('work_group_id', workGroup.toString());
		if (end_date) {
			const _endDate = new Date(end_date);
			const isoDate = _endDate.toISOString();
			const dateString = `${isoDate.slice(0, 10)}T${_endDate.getHours()}:${_endDate.getMinutes()}`;
			formData.append('end_date', dateString);
		} else {
			formData.append('end_date', '');
		}

		description = description.trim() === '' ? $_('No description provided') : description;
		formData.append('description', description);
		if (images) {
			images.forEach((image) => {
				formData.append('attachments', image);
			});
		}

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
		const _assignee = assignee
			? {
					id: assignee,
					profile_image: userAssigned?.user.profile_image || '',
					username: userAssigned?.user.username || ''
			  }
			: null;

		kanbanEntries.push({
			assignee: _assignee,
			group: { id: 0, image: '', name: '' },
			description,
			lane,
			title,
			id: json,
			created_by: {
				id: Number(localStorage.getItem('userId')),
				profile_image: localStorage.getItem('pfp-link') || '',
				username: localStorage.getItem('userName') || ''
			},
			origin_id: 1,
			origin_type: type === 'group' ? 'group' : 'user',
			group_name: '',
			priority,
			end_date: end_date || null,
			work_group: workGroup
				? {
						id: workGroup,
						name: workGroups.find((group) => group.id === workGroup)?.name || ''
				  }
				: undefined,
			attachments: []
		});

		kanbanEntries = kanbanEntries;
		open = false;

		// Reset form
		description = '';
		title = '';
		assignee = null;
		priority = 3;
		end_date = null;
		images = [];
		workGroup = workGroups[0]?.id || undefined;

		await getKanbanEntries(); // Refresh entries immediately
	};

	const handleChangeAssignee = (e: any) => {
		assignee = Number(e.target.value);
	};

	const handleChangePriority = (e: any) => {
		priority = Number(e.target.value);
	};

	const handleChangeWorkGroup = (e: any) => {
		workGroup =
			workGroups.find((group) => group.id === Number(e.target.value))?.id || workGroups[0]?.id;
	};
</script>

<Modal bind:open Class="min-w-[400px] max-w-[500px]" onSubmit={createKanbanEntry}>
	<div slot="body">
		<Loader bind:loading>
			<div on:submit|preventDefault={createKanbanEntry}>
				<div class="pb-2">
					<TextInput Class="text-md" required label="Title" bind:value={title} />
				</div>
				<TextArea
					Class="text-md"
					inputClass="whitespace-pre-wrap"
					label="Description"
					bind:value={description}
				/>

				{#if type === 'group' && workGroups?.length > 0}
					<div class="text-left">
						<label class="block text-md" for="work-group">
							{$_('Work Group')}
						</label>
						<Select
							Class="w-full"
							classInner="rounded p-1 border border-gray-300 dark:border-gray-600 dark:bg-darkobject"
							labels={workGroups.map((group) => elipsis(group.name))}
							values={workGroups.map((group) => group.id)}
							bind:value={workGroup}
							defaultValue=""
							onInput={handleChangeWorkGroup}
							innerLabel={$_('No workgroup assigned')}
							innerLabelOn={true}
						/>
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
						placeholder={$_('No end date set')}
					/>
				</div>
				<div class="text-left">
					<label for="handleChangePriority" class="block text-md pt-2">
						{$_('Priority')}
					</label>
					<Select
						Class="w-full"
						classInner="rounded p-1 border border-gray-300 dark:border-gray-600 dark:bg-darkobject"
						labels={priorities.map((i) => $_(priorityText[priorityText.length - i]))}
						values={priorities}
						bind:value={priority}
						onInput={handleChangePriority}
						innerLabel=""
					/>
					<div class="flex gap-6 justify-between mt-2 flex-col" />

					{#if type === 'group'}
						<div class="text-left">
							<label class="block text-md" for="handle-change-assignee">
								{$_('Assignee')}
							</label>
							<Select
								Class="w-full"
								classInner="rounded p-1 border border-gray-300 dark:border-gray-600 dark:bg-darkobject"
								labels={users.map((user) => user.user.username)}
								values={users.map((user) => user.user.id)}
								bind:value={assignee}
								defaultValue=""
								onInput={handleChangeAssignee}
								innerLabel={$_('No assignee')}
								innerLabelOn={true}
							/>
						</div>
					{/if}
					<div class="text-left">
						<span class="block text-md">
							{$_('Attachments')}
						</span>
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
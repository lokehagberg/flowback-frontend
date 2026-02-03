<script lang="ts">
	import { _ } from 'svelte-i18n';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import FileUploads from '$lib/Generic/File/FileUploads.svelte';
	import type { GroupUser } from '../interface';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { WorkGroup, WorkGroupUser } from '../WorkingGroups/interface';
	import Select from '$lib/Generic/Select.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import GroupSelection from '$lib/Generic/GroupSelection.svelte';
	import { groupMembers as groupMembersLimit } from '$lib/Generic/APILimits.json';

	export let open: boolean = false,
		workGroups: WorkGroup[] = [],
		lane: number = 1,
		getKanbanEntries: () => Promise<void>;

	let users: GroupUser[] = [],
		workgroupUsers: GroupUser[] = [],
		description = '',
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
		images: File[] = [],
		selectedWorkgroupId: number | null = null,
		selectedGroupId: number | null = null;

	const createKanbanEntry = async () => {
		loading = true;

		const formData = new FormData();

		formData.append('title', title);
		formData.append('tag', lane.toString());
		formData.append('lane', lane.toString());

		if (assignee) formData.append('assignee_id', assignee.toString());
		if (priority) formData.append('priority', priority.toString());
		if (selectedWorkgroupId)
			formData.append('work_group_id', selectedWorkgroupId.toString());
		if (end_date) formData.append('end_date', end_date);

		description =
			description.trim() === '' ? $_('No description provided') : description;

		formData.append('description', description);
		images.forEach((image) => {
			formData.append('attachments', image);
		});

		const { res, json } = await fetchRequest(
			'POST',
			selectedGroupId
				? `group/${selectedGroupId}/kanban/entry/create`
				: 'user/kanban/entry/create',
			formData,
			true, // Needs authorization
			false // Formadata doesn't need to be JSON-fied
		);

		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to create kanban task',
				success: false
			});
			return;
		}

		ErrorHandlerStore.set({
			message: 'Successfully created kanban task',
			success: true
		});

		open = false;

		// Reset form
		description = '';
		title = '';
		assignee = null;
		priority = 3;
		end_date = new Date().toISOString().slice(0, 16); // Reset to current date/time
		images = [];
		selectedWorkgroupId = workGroups[0]?.id ?? null;

		await getKanbanEntries();
	};

	const handleChangeAssignee = (e: any) => {
		assignee = Number(e.target.value);
	};

	const handleChangePriority = (e: any) => {
		priority = Number(e.target.value);
	};

	const getUsers = async () => {
		if (!selectedGroupId) {
			users = [];
			return;
		}

		const { res, json } = await fetchRequest(
			'GET',
			`group/${selectedGroupId}/users?limit=${groupMembersLimit}`
		);

		if (res.ok) users = json?.results ?? [];
	};

	const getWorkgroupUsers = async () => {
		if (!selectedWorkgroupId || !selectedGroupId) {
			workgroupUsers = [];
			return;
		}

		const { res, json } = await fetchRequest(
			'GET',
			`group/workgroup/${selectedWorkgroupId}/list?limit=${groupMembersLimit}`
		);

		if (res.ok) {
			workgroupUsers =
				json?.results?.map((u: WorkGroupUser) => u.group_user) ?? [];
			users = users.filter((u: GroupUser) =>
				workgroupUsers.find((k) => k.id === u.id)
			);
		}
	};

	$: selectedGroupId, getUsers();
	$: selectedWorkgroupId, getWorkgroupUsers();
</script>

<Modal
	bind:open
	Class="min-w-[400px] max-w-[500px]"
	onSubmit={createKanbanEntry}
	id="create-kanban-entry-modal"
>
	<div slot="header">
		<h2 class="text-xl">{$_('Create Kanban Entry')}</h2>
	</div>
	<div slot="body">
		<Loader bind:loading>
			<div on:submit|preventDefault={createKanbanEntry}>
				<div class="pb-2">
					<TextInput
						id="create-kanban-text"
						Class="text-md"
						required
						label="Title"
						bind:value={title}
					/>
				</div>
				<TextArea
					id={`create-kanban-textarea`}
					Class="text-md"
					inputClass="whitespace-pre-wrap"
					label="Description"
					bind:value={description}
				/>

				<GroupSelection bind:selectedGroupId bind:selectedWorkgroupId />
				<div class="text-left">
					<label class="block text-md pt-2" for="end_date">
						{$_('End date')}
					</label>
					<input
						bind:value={end_date}
						class="w-full border rounded p-1 border-gray-300 dark:border-gray-600 bg-white dark:bg-darkobject
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
						classInner="rounded p-1 border border-gray-300 dark:border-gray-600 bg-white dark:bg-darkobject"
						labels={priorities.map((i) =>
							$_(priorityText[priorityText.length - i])
						)}
						values={priorities}
						bind:value={priority}
						onInput={handleChangePriority}
						innerLabel=""
					/>

					<div class="text-left">
						<label class="block text-md" for="handle-change-assignee">
							{$_('Assignee')}
						</label>

						<Select
							Class="w-full"
							classInner="rounded p-1 border border-gray-300 dark:border-gray-600 bg-white dark:bg-darkobject"
							labels={users.map((user) => user.user.username)}
							values={users.map((user) => user.user.id)}
							bind:value={assignee}
							onInput={handleChangeAssignee}
							innerLabel={$_('No assignee')}
							innerLabelOn={true}
							innerLabelValue={null}
						/>
					</div>

					<div class="text-left">
						<span class="block text-md">
							{$_('Attachments')}
						</span>
						<FileUploads bind:files={images} disableCropping />
					</div>
				</div>
			</div>
		</Loader>
	</div>

	<div slot="footer" class="flex">
		<Button Class="py-1 flex-1" buttonStyle="primary" type="submit"
			>{$_('Confirm')}</Button
		>
		<Button
			Class="py-1 flex-1"
			buttonStyle="warning"
			onClick={() => (open = false)}
			>{$_('kanbanEntry.Cancel', { default: 'Cancel' })}</Button
		>
	</div>
</Modal>

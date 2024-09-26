<script lang="ts">
	import KanbanEntry from './KanbanEntry.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { _ } from 'svelte-i18n';
	import type { GroupUser, kanban } from '../interface';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { onDestroy, onMount } from 'svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { DateInput } from 'date-picker-svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { kanban as kanbanLimit } from '../../Generic/APILimits.json';
	import Modal from '$lib/Generic/Modal.svelte';
	import Filter from '$lib/Generic/Filter.svelte';
	import FileUploads from '$lib/Generic/FileUploads.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';

	const tags = ['', 'Backlog', 'To do', 'Current', 'Evaluation', 'Done'];
	//TODO: the interfaces "kanban" and "KanbanEntry" are equivalent, make them use the same interface.
	let kanbanEntries: kanban[] = [],
		description = '',
		title = '',
		assignee: number | null = null,
		users: GroupUser[] = [],
		status: StatusMessageInfo,
		poppup: poppup,
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
		interval: any,
		open = false,
		numberOfOpen = 0,
		filter: { assignee: number | null } = { assignee: null },
		images: File[];

	export let type: 'home' | 'group',
		Class = '';

	const changeNumberOfOpen = (addOrSub: 'Addition' | 'Subtraction') => {
		if (numberOfOpen < 0) numberOfOpen = 0;

		if (addOrSub === 'Addition') numberOfOpen += 1;
		if (addOrSub === 'Subtraction') numberOfOpen -= 1;
	};

	onMount(() => {
		getKanbanEntries();

		interval = setInterval(() => {
			// console.log(numberOfOpen, "OPEN")
			if (numberOfOpen === 0) getKanbanEntries();
		}, 20000);
	});

	//TODO fix this
	onDestroy(() => {
		clearInterval(interval);
	});

	const getKanbanEntries = async () => {
		if (type === 'group') {
			getGroupUsers();
			getKanbanEntriesGroup();
		} else if (type === 'home') getKanbanEntriesHome();
	};

	const getKanbanEntriesGroup = async () => {
		let api = `group/${$page.params.groupId}/kanban/entry/list?limit=${kanbanLimit}&order_by=priority_desc`;
		if (filter.assignee !== null) api += `&assignee=${filter.assignee}`;

		const { res, json } = await fetchRequest('GET', api);

		if (!res.ok) status = statusMessageFormatter(res, json);
		kanbanEntries = json.results;
	};

	const getKanbanEntriesHome = async () => {
		assignee = Number(localStorage.getItem('userId')) || 1;
		// const user = await fetchRequest('GET', 'user');
		const { res, json } = await fetchRequest(
			'GET',
			`user/kanban/entry/list?limit=${kanbanLimit}&order_by=priority_desc`
		);

		if (!res.ok) status = statusMessageFormatter(res, json);
		kanbanEntries = json.results;
	};

	const handleChangeAssignee = (e: any) => {
		assignee = Number(e.target.value);
	};

	const handleChangePriority = (e: any) => {
		priority = Number(e.target.value);
	};

	const getGroupUsers = async () => {
		let api = `group/${$page.params.groupId}/users?limit=${kanbanLimit}`;

		const { json } = await fetchRequest('GET', api);
		users = json.results;
		if (!assignee) assignee = users[0]?.user.id;
	};

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

		status = statusMessageFormatter(res, json);
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

	const removeKanbanEntry = (id: number) => {
		kanbanEntries = kanbanEntries.filter((entry) => entry.id !== id);
	};
</script>

<Poppup bind:poppup />

<div
	class={' dark:bg-darkobject dark:text-darkmodeText p-2 rounded-2xl break-words md:max-w-[calc(500px*5)]' +
		Class}
>
	<!-- <Filter
		bind:filter
		handleSearch={getKanbanEntries}
		iterables={users.map((user) => {
			return { name: user.user.username, id: user.user.id };
		})}
	/> -->
	<div class="flex overflow-x-auto">
		<!-- {#await promise}
			<div>Loading...</div>
		{:then kanbanEntries} -->
		{#each tags as tag, i}
			{#if i !== 0}
				<div
					class="bg-white inline-block min-w-[120px] max-w-[500px] w-1/5 p-1 m-1 dark:bg-darkbackground dark:text-darkmodeText border-gray-200 rounded-xl"
				>
					<!-- "Tag" is the name for the titles on the kanban such as "To Do" etc. -->
					<span class="xl:text-xl text-md p-1">{$_(tag)}</span>
					<ul class="flex flex-col mt-2 gap-4">
						{#each kanbanEntries as kanban}
							{#if kanban.tag === i}
								<KanbanEntry bind:kanban {users} {type} {removeKanbanEntry} {changeNumberOfOpen} />
							{/if}
						{/each}
					</ul>
				</div>
			{/if}
		{/each}
		<!-- {/await} -->
	</div>
	<div class="mt-4 ml-2 mb-4">
		<Button action={() => (open = true)}>{$_('Create Task')}</Button>
	</div>
</div>

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
							Assignee
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
						{$_('End date')}
						<DateInput bind:value={end_date} min={new Date()} />
					</div>
				</div>
				<FileUploads bind:images />
				<!-- <StatusMessage Class="mt-2" bind:status /> -->
			</div>
		</Loader>
	</div>
	<div slot="footer">
		<Button Class="" type="submit">{$_('Create task')}</Button>
	</div>
</Modal>

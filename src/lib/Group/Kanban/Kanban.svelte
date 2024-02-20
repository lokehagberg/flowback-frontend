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
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import { DateInput } from 'date-picker-svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { kanban as kanbanLimit } from '../../Generic/APILimits.json';
	import Modal from '$lib/Generic/Modal.svelte';

	const tags = ['', 'Backlog', 'To do', 'Current', 'Evaluation', 'Done'];
	//TODO: the interfaces "kanban" and "KanbanEntry" are equivalent, make them use the same interface.
	let kanbanEntries: kanban[] = [];
	let description = '',
		title = '',
		assignee: number | null = null,
		users: GroupUser[] = [],
		status: StatusMessageInfo,
		showSuccessPoppup = false,
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
		numberOfOpen = 0;

	export let type: 'home' | 'group',
		Class = '';
		
	const changeNumberOfOpen = (addOrSub : 'Addition' | 'Subtraction') => {
		if (numberOfOpen < 0) numberOfOpen = 0

		if (addOrSub === 'Addition') numberOfOpen += 1
		if (addOrSub === 'Subtraction') numberOfOpen -= 1
	}

	onMount(() => {
		getKanbanEntries();

		interval = setInterval(() => {
			// console.log(numberOfOpen, "OPEN")
			if (numberOfOpen === 0)
				getKanbanEntries();
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
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/kanban/entry/list?limit=${kanbanLimit}&order_by=priority_desc`
		);
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
		const { json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?limit=${kanbanLimit}`
		);
		users = json.results;
		if (!assignee) assignee = users[0]?.user.id;
	};

	const createKanbanEntry = async () => {
		loading = true;
		const content = priority
			? {
					assignee,
					description,
					tag: 1,
					title,
					priority,
					end_date
			  }
			: {
					assignee,
					description,
					tag: 1,
					title,
					end_date
			  };
		const { res, json } = await fetchRequest(
			'POST',
			type === 'group'
				? `group/${$page.params.groupId}/kanban/entry/create`
				: 'user/kanban/entry/create',
			content
		);
		status = statusMessageFormatter(res, json);
		loading = false;

		if (!res.ok) return;

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

		showSuccessPoppup = true;
	};

	const removeKanbanEntry = (id: number) => {
		kanbanEntries = kanbanEntries.filter((entry) => entry.id !== id);
	};
</script>

<SuccessPoppup bind:show={showSuccessPoppup} />

<div
	class={'bg-white dark:bg-darkobject dark:text-darkmodeText p-2 rounded-2xl break-words md:max-w-[calc(500px*5)]' +
		Class}
>
	<div class="flex overflow-x-auto">
		<!-- {#await promise}
			<div>Loading...</div>
		{:then kanbanEntries} -->
		{#each tags as tag, i}
			{#if i !== 0}
				<div
					class="inline-block min-w-[120px] max-w-[500px] w-1/5 p-1 m-1 dark:bg-darkbackground dark:text-darkmodeText border-gray-200 rounded-xl bg-white"
				>
					<!-- "Tag" is the name for the titles on the kanban such as "To Do" etc. -->
					<span class="xl:text-xl text-md p-1">{$_(tag)}</span>
					<ul class="flex flex-col mt-2 gap-4">
						{#each kanbanEntries as kanban}
							{#if kanban.tag === i}
								<KanbanEntry bind:kanban {type} {users} {removeKanbanEntry} {changeNumberOfOpen} />
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
<Modal bind:open Class="!overflow-visible">
	<div slot="header">{$_('Create Task')}</div>
	<div slot="body">
		<Loader bind:loading>
			<form on:submit|preventDefault={createKanbanEntry} class="mt-2">
				<TextInput required label="Title" bind:value={title} />
				<TextArea required label="Description" bind:value={description} />
				<div class="flex gap-6 justify-between mt-2">
					{#if type === 'group'}
						<select
							on:input={handleChangeAssignee}
							class="dark:bg-darkobject border border-gray-600"
						>
							{#each users as user}
								<option value={user.user.id}>{user.user.username}</option>
							{/each}
						</select>
					{/if}
					<div>
						{$_('Priority')}
						<select
							class="border border-gray-600 dark:bg-darkobject"
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
					<div>
						{$_('End date')}
						<DateInput bind:value={end_date} min={new Date()} />
					</div>
				</div>
				<Button type="submit">{$_('Create task')}</Button>
				<!-- <StatusMessage Class="mt-2" bind:status /> -->
			</form>
		</Loader>
	</div>
</Modal>

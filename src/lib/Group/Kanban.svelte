<script lang="ts">
	import KanbanEntry from './KanbanEntry.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { _ } from 'svelte-i18n';
	import type { GroupUser, kanban, User } from './interface';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { onMount } from 'svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import { DateInput, DatePicker } from 'date-picker-svelte';

	const tags = ['', 'Backlog', 'To do', 'Current', 'Evaluation', 'Done'];
	//TODO: the interfaces "kanban" and "KanbanEntry" are equivalent, make them use the same interface.
	let kanbanEntries: kanban[] = [];
	let description = '',
		title = '',
		assignee = 0,
		users: GroupUser[] = [],
		status: StatusMessageInfo,
		showSuccessPoppup = false,
		priorities = [1, 2, 3, 4, 5],
		priority = 1,
		end_date: null | Date = null;

	export let type: 'home' | 'group',
		Class = '';

	onMount(() => {
		getKanbanEntries();
	});

	const getKanbanEntries = async () => {
		if (type === 'group') {
			getKanbanEntriesGroup();
			if (type === 'group') getGroupUsers();
		} else if (type === 'home') getKanbanEntriesHome();
	};

	const getKanbanEntriesGroup = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/kanban/entry/list?limit=10000&order_by=priority`
		);
		if (!res.ok) status = statusMessageFormatter(res, json);
		kanbanEntries = json.results;
	};

	const getKanbanEntriesHome = async () => {
		assignee = Number(localStorage.getItem('userId')) || 1;
		// const user = await fetchRequest('GET', 'user');
		const { res, json } = await fetchRequest('GET', `user/kanban/entry/list?limit=10000`);
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
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/users?limit=100`);
		users = json.results;
		assignee = users[0]?.user.id;
	};

	const createKanbanEntry = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			type === 'group'
				? `group/${$page.params.groupId}/kanban/entry/create`
				: 'user/kanban/entry/create',
			{
				assignee,
				description,
				tag: 1,
				title,
				priority,
				end_date
			}
		);
		status = statusMessageFormatter(res, json);

		if (!res.ok) return;

		const userAssigned = users.find((user) => assignee === user.user.id);
		// if (userAssigned)
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
			end_date:end_date?.toString() || null
		});

		kanbanEntries = kanbanEntries;

		description = '';
		title = '';

		showSuccessPoppup = true;
	};

	const removeKanbanEntry = (id: number) => {
		kanbanEntries = kanbanEntries.filter((entry) => entry.id !== id);
		getKanbanEntries();
	};
</script>

<SuccessPoppup bind:show={showSuccessPoppup} />

<div class={'bg-white p-2 rounded-2xl ' + Class}>
	<div class="flex overflow-x-auto">
		<!-- <StatusMessage bind:status disableSuccess/> -->
		<!-- {#await promise}
			<div>Loading...</div>
		{:then kanbanEntries} -->
		{#each tags as tag, i}
			{#if i !== 0}
				<div
					class="inline-block min-w-[200px] w-1/5 p-1 m-1 bg-gray-100 border-gray-200 rounded-xl"
				>
					<!-- "Tag" is the name for the titles on the kanban such as "To Do" e.tc -->
					<span class="xl:text-xl text-md p-1">{$_(tag)}</span>
					<ul class="flex flex-col mt-2">
						{#each kanbanEntries as kanban}
							{#if kanban.tag === i}
								<KanbanEntry bind:kanban {type} {users} {removeKanbanEntry} />
							{/if}
						{/each}
					</ul>
				</div>
			{/if}
		{/each}
		<!-- {/await} -->
	</div>
	<div class="pl-4 pr-4 pb-4">
		<h1 class="mt-4 text-left text-2xl">{$_('Create task')}</h1>
		<form on:submit|preventDefault={createKanbanEntry} class="mt-2">
			<TextInput required label="Title" bind:value={title} />
			<TextArea required label="Description" bind:value={description} />
			<div class="flex gap-6 justify-between mt-2">
				{#if type === 'group'}
					<select on:input={handleChangeAssignee} class="border border-gray-600">
						{#each users as user}
							<option value={user.user.id}>{user.user.username}</option>
						{/each}
					</select>
				{/if}
				{$_("Priority")}
				<select class="border border-gray-600" on:input={handleChangePriority}>
					{#each priorities as i}
						<option value={i}>{i}</option>
					{/each}
				</select>
				{$_("End date")}
				<DateInput bind:value={end_date} min={new Date()}/>
				<Button type="submit">{$_('Create task')}</Button>
			</div>
			<StatusMessage Class="mt-2" bind:status />
		</form>
	</div>
</div>

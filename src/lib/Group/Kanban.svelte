<script lang="ts">
	import KanbanEntry from './KanbanEntry.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { _ } from 'svelte-i18n';
	import type { kanban, User } from './interface';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { onMount } from 'svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';

	const tags = ['', 'Backlog', 'To do', 'Current', 'Evaluation', 'Done'];
	let kanbanEntries: kanban[] = [];
	let description = '',
		title = '',
		assignee = 0,
		users: User[] = [],
		status: StatusMessageInfo;

	export let type: 'home' | 'group',
		Class = '';

	onMount(() => {
		if (type === 'group') {
			getKanbanEntries();
			getGroupUsers();
		} else if (type === 'home') getKanbanEntriesHome();
	});

	const getKanbanEntries = async () => {
		const { res, json } = await fetchRequest('GET', `group/${$page.params.groupId}/kanban/list`);
		if (!res.ok)
		status = statusMessageFormatter(res, json);
		kanbanEntries = json.results;
	};
	
	const getKanbanEntriesHome = async () => {
		const user = await fetchRequest('GET', 'user');
		const { res, json } = await fetchRequest('GET', `home/kanban?assignee=${user.json.id}`);
		if (!res.ok)
		status = statusMessageFormatter(res, json);
		kanbanEntries = json.results;
	};

	const handleChangeAssignee = (e: any) => {
		assignee = Number(e.target.value);
	};

	const getGroupUsers = async () => {
		const { json } = await fetchRequest('GET', `group/${$page.params.groupId}/users?limit=100`);
		users = json.results;
		assignee = json.results[0].user_id;
	};

	const createKanbanEntry = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/kanban/create`,
			{
				assignee,
				description,
				tag: 1,
				title
			}
		);
		status = statusMessageFormatter(res, json);

		if (!res.ok) return;

		const userAssigned = users.find((user) => assignee === user.user_id);
		if (userAssigned)
			kanbanEntries.push({
				assignee: {
					id: assignee,
					profile_image: userAssigned.profile_image || '',
					username: userAssigned.username
				},
				group: { id: 0, image: '', name: '' },
				description,
				tag: 1,
				title,
				id: json,
				created_by: 1
			});

		kanbanEntries = kanbanEntries;

		description = '';
		title = '';
	};

	const removeKanbanEntry = (id: number) => {
		kanbanEntries = kanbanEntries.filter((entry) => entry.id !== id);
	};
</script>

<div class={'bg-white p-2 rounded-2xl ' + Class}>
	<div class="flex overflow-x-auto">
		<StatusMessage bind:status disableSuccess/>
		<!-- {#await promise}
			<div>Loading...</div>
		{:then kanbanEntries} -->
		{#each tags as tag, i}
			{#if i !== 0}
				<div class="inline-block min-w-[200px] p-1 m-1 bg-gray-100 border-gray-200 rounded-xl">
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
	{#if type === 'group'}
		<div class="pl-4 pr-4 pb-4">
			<h1 class="mt-4 text-left text-2xl">{$_('Create task')}</h1>
			<form on:submit|preventDefault={createKanbanEntry} class="mt-2">
				<TextInput required label="Title" bind:value={title} />
				<TextArea required label="Description" bind:value={description} />
				<div class="flex gap-6 justify-between mt-2">
					<select on:input={handleChangeAssignee} class="border border-gray-600">
						{#each users as user}
							<option value={user.user_id}>{user.username}</option>
						{/each}
					</select>
					<Button type="submit">{$_('Create task')}</Button>
				</div>
				<StatusMessage Class="mt-2" bind:status />
			</form>
		</div>
	{/if}
</div>

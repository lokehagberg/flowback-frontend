<script lang="ts">
	import KanbanEntry from './KanbanEntry.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { _ } from 'svelte-i18n';
	import Modal from '$lib/Generic/Modal.svelte';
	import type { kanban, User } from './interface';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { onMount } from 'svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';

	const tags = ['', 'Backlog', 'To do', 'Current', 'Evaluation', 'Done'];
	let kanbanEntries: kanban[] = [];
	let openModal = false;
	let description = '',
		title = '',
		assignee = 0,
		users: User[] = [],
		status: StatusMessageInfo,
		selectedEntry: number;

	export let type: 'home' | 'group',
		Class = '';

	onMount(() => {
		if (type === 'group') {
			getKanbanEntries();
			getGroupUsers();
		} else if (type === 'home') getKanbanEntriesHome();
	});

	const getKanbanEntries = async () => {
		const { res, json } = await fetchRequest('GET', `group/${$page.params.groupId}/kanban`);
		statusMessageFormatter(res, json);
		kanbanEntries = json.results;
	};

	const getKanbanEntriesHome = async () => {
		const user = await fetchRequest('GET', 'user');
		const { res, json } = await fetchRequest('GET', `home/kanban?assignee=${user.json.id}`);
		statusMessageFormatter(res, json);
		kanbanEntries = json.results;
	};

	const handleUpdateKanban = async (kanban: any) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/kanban/${kanban.id}/update`,
			kanban
		);
		statusMessageFormatter(res, json);
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
		console.log(users, assignee);
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

	//Untested
	const deleteKanbanEntry = async (id: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/kanban/${id}/delete`,
			{
				kanban_entry_id: id
			}
		);
		statusMessageFormatter(res, json);
	};
</script>

<div class={'mt-6 bg-white p-2 rounded-2xl ' + Class}>
	<div class="flex justify-between">
		<!-- {#await promise}
			<div>Loading...</div>
		{:then kanbanEntries} -->
		{#each tags as tag, i}
			{#if i !== 0}
				<div class="flex-1 p-1 m-1 bg-gray-100 border-gray-200 rounded-xl">
					<!-- "Tag" is the name for the titles on the kanban such as "To Do" e.tc -->
					<span class="text-sm p-1">{$_(tag)}</span>
					<ul class="flex flex-col mt-2">
						{#each kanbanEntries as kanban}
							{#if kanban.tag === i}
								<KanbanEntry bind:kanban {type} {handleUpdateKanban} />
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
			<h1 class="mt-4 text-left">{$_('Create task')}</h1>
			<form on:submit|preventDefault={createKanbanEntry}>
				<TextInput required label="Title" bind:value={title} />
				<TextArea required label="Description" bind:value={description} />
				<select on:input={handleChangeAssignee}>
					{#each users as user}
						<option value={user.user_id}>{user.username}</option>
					{/each}
				</select>
				<ButtonPrimary type="submit">{$_('Create task')}</ButtonPrimary>
				<StatusMessage Class="mt-2" bind:status />
			</form>
		</div>
	{/if}
</div>

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons/faArrowLeft';
	import { faArrowRight } from '@fortawesome/free-solid-svg-icons/faArrowRight';
	import Modal from '$lib/Generic/Modal.svelte';
	import type { kanban, User } from './interface';
	import { page } from '$app/stores';
	import { fade } from 'svelte/transition';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { onMount } from 'svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';

	const tags = ['', 'Backlog', 'To Do', 'In Progress', 'Evaluation', 'Done'];
	let kanbanEntries: kanban[] = [];
	let openModal = false;
	let description = '',
		title = '',
		assignee = 0,
		users: User[] = [],
		status: StatusMessageInfo,
		selectedEntry: number;
	
	export let type: 'home' | 'group'

	onMount(() => {
		if (type === 'group') getKanbanEntries();
		else if (type === 'home') getKanbanEntriesHome();

		getGroupUsers();
	});

	const getKanbanEntries = async () => {
		const { res, json } = await fetchRequest('GET', `group/${$page.params.groupId}/kanban`);
		statusMessageFormatter(res, json);
		kanbanEntries = json.results;
	};
	
	const getKanbanEntriesHome = async () => {
		const { res, json } = await fetchRequest('GET', 'home/kanban');
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
		const userAssigned = users.find((user) => assignee === user.user_id);
		console.log(users, assignee);
		if (userAssigned)
			kanbanEntries.push({
				assignee: {
					id: assignee,
					profile_image: userAssigned.profile_image || '',
					username: userAssigned.username
				},
				description,
				tag: 1,
				title,
				id: json,
				created_by: 1
			});
		kanbanEntries = kanbanEntries;
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

<div class="bg-white p-2 rounded-2xl">
	<div class="flex justify-between">
		<!-- {#await promise}
			<div>Loading...</div>
		{:then kanbanEntries} -->
		{#each tags as tag, i}
			{#if i !== 0}
			<div class="flex-1 p-1 m-1 bg-gray-100 border-gray-200 rounded-xl">
				<!-- "Tag" is the name for the titles on the kanban such as "To Do" e.tc -->
				<span class="text-sm p-1">{tag}</span>
				<ul class="flex flex-col mt-2">
					{#each kanbanEntries as kanban}
						{#if kanban.tag === i}
							<li class="bg-white border border-gray-200 hover:bg-gray-200 p-2" in:fade>
								<div
									on:click={() => {
										openModal = true;
										selectedEntry = kanban.id;
									}}
									class="cursor-pointer hover:underline"
								>
									<div class="text-sm break-all">{kanban.title}</div>
								</div>
								<div class="mt-2 flex gap-2 items-center text-sm">
									<ProfilePicture user={kanban.assignee} />
									<div class="break-all">{kanban.assignee.username}</div>
								</div>
								<div class="flex justify-between mt-3">
									<div
										class="cursor-pointer hover:text-gray-500"
										on:click={() => {
											if (kanban.tag > 0) {
												handleUpdateKanban({ id: kanban.id, tag: kanban.tag - 1 });
												kanban.tag -= 1;
											}
										}}
									>
										<Fa icon={faArrowLeft} size="1.5x" />
									</div>
									<div
										class="cursor-pointer hover:text-gray-500"
										on:click={() => {
											if (kanban.tag < tags.length) {
												handleUpdateKanban({ id: kanban.id, tag: kanban.tag + 1 });
												kanban.tag += 1;
											}
										}}
									>
										<Fa icon={faArrowRight} size="1.5x" />
									</div>
								</div>
							</li>
							{#if kanban.id === selectedEntry}
								<Modal bind:open={openModal}>
									<div slot="header" class="p-4">{kanban.title}</div>
									<div slot="body" class="p-5">
										{kanban.description}
									</div>
								</Modal>
							{/if}
						{/if}
					{/each}
				</ul>
			</div>
			{/if}
		{/each}
		<!-- {/await} -->
	</div>
	{#if type === "group"}
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

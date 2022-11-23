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

	const tags = ['Backlog', 'To Do', 'In Progress', 'Evaluation', 'Done'];
	let kanbanEntries: kanban[] = [];
	let openModal = false;
	let description = '',
		title = '',
		assignee = 0,
		users: User[] = [],
		status: StatusMessageInfo;

	onMount(() => {
		getKanbanEntries();
		getGroupUsers();
	});

	const getKanbanEntries = async () => {
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
		assignee = e.target.value;
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
		kanbanEntries.push({
			assignee: {id:assignee, profile_image:"", username:"test"},
			description,
			tag: 1,
			title,
            id: json,
            created_by: 1
		});
        kanbanEntries = kanbanEntries
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

<div class="bg-white p-6">
	<div class="flex justify-between">
		<!-- {#await promise}
			<div>Loading...</div>
		{:then kanbanEntries} -->
		{#each tags as tag, i}
			<div class="flex-1">
				<span class="font-bold text-xl">{tag}</span>
				<ul class="flex flex-col mt-2">
					{#each kanbanEntries as kanban}
						{#if kanban.tag === i}
							<li class="border border-gray-200 hover:bg-gray-200 p-2" in:fade>
								<div on:click={() => (openModal = true)} class="cursor-pointer hover:underline">
									<div class="text-xl">{kanban.title}</div>
								</div>
								<div class="mt-2 flex gap-2 items-center">
									<ProfilePicture user={kanban.assignee} />
									<div>{kanban.assignee.username}</div>
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
							<Modal bind:open={openModal}>
								<div slot="header">{kanban.title}</div>
								<div slot="body">
									{kanban.description}
								</div>
							</Modal>
						{/if}
					{/each}
				</ul>
			</div>
		{/each}
		<!-- {/await} -->
	</div>
	<h1 class="mt-4 text-left">{$_('Create Task')}</h1>
	<form on:submit|preventDefault={createKanbanEntry}>
		<TextInput required label="title" bind:value={title} />
		<TextArea required label="description" bind:value={description} />
		<select on:input={handleChangeAssignee}>
			{#each users as user}
				<option value={user.user_id}>{user.username}</option>
			{/each}
		</select>
		<ButtonPrimary type="submit">{$_('Create task')}</ButtonPrimary>
		<StatusMessage Class="mt-2" bind:status />
	</form>
</div>

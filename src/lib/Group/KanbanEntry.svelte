<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons/faArrowLeft';
	import { faArrowRight } from '@fortawesome/free-solid-svg-icons/faArrowRight';
	import { fade } from 'svelte/transition';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { page } from '$app/stores';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';

	const tags = ['', 'Backlog', 'To do', 'In progress', 'Evaluation', 'Done'];
	let openModal = false,
		selectedEntry: number;

	export let kanban: any, type: 'group' | 'home', users: any[], removeKanbanEntry : (id:number) => void;

	// initializes the kanban to be edited when modal is opened
	let kanbanEdited = {
		id: kanban.id,
		description: kanban.description,
		title: kanban.title,
		assignee: kanban.assignee.id
	};

	const updateKanbanContent = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/kanban/${kanban.id}/update`,
			kanbanEdited
		);
		kanban.title = kanbanEdited.title;
		kanban.description = kanbanEdited.description;
		statusMessageFormatter(res, json);
	};

	const updateKanbanTag = async (kanban: any) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/kanban/${kanban.id}/update`,
			kanban
		);
		statusMessageFormatter(res, json);
	};

	const changeAssignee = (e: any) => {
		kanbanEdited.assignee = Number(e.target.value);
	};

	// Delete kanban removes it from the database, 
	// remove kanban removes the displaying of the kanban.
	const deleteKanbanEntry = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/kanban/${kanban.id}/delete`
		);
		statusMessageFormatter(res, json);
		removeKanbanEntry(kanban.id)
	};
</script>

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
	<div
		class="mt-2 gap-2 items-center text-sm cursor-pointer hover:underline"
		on:click={() =>
			(window.location.href =
				type === 'group' ? `/user?id=${kanban.assignee.id}` : `groups/${kanban.group.id}`)}
	>
		<ProfilePicture user={type === 'group' ? kanban.assignee : kanban.group} />
		<div class="break-all">
			{type === 'group' ? kanban.assignee.username : kanban.group.name}
		</div>
	</div>
	<!-- Arrows -->
	{#if type === 'group'}
		<div class="flex justify-between mt-3">
			<div
				class="cursor-pointer hover:text-gray-500"
				on:click={() => {
					if (kanban.tag > 0) {
						updateKanbanTag({ id: kanban.id, tag: kanban.tag - 1 });
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
						updateKanbanTag({ id: kanban.id, tag: kanban.tag + 1 });
						kanban.tag += 1;
					}
				}}
			>
				<Fa icon={faArrowRight} size="1.5x" />
			</div>
		</div>
	{/if}
</li>

{#if kanban.id === selectedEntry}
	<Modal bind:open={openModal}>
		<TextInput slot="header" bind:value={kanbanEdited.title} label="" />
		<div slot="body">
			<TextArea bind:value={kanbanEdited.description} label="" />
			<select on:input={changeAssignee}>
				{#each users as user}
					<option value={user.user_id}>{user.username}</option>
				{/each}
			</select>
		</div>
		<div slot="footer">
			<ButtonPrimary action={updateKanbanContent}>Update</ButtonPrimary>
			<ButtonPrimary action={deleteKanbanEntry} Class="bg-red-500">Delete</ButtonPrimary>
		</div>
	</Modal>
{/if}

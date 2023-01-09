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

	export let kanban: any,
		type: 'group' | 'home',
		handleUpdateKanban = (kanban: any) => {};

	let kanbanEdited = kanban
	
	const updateKanban = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/kanban/${kanban.id}/update`,
			{...kanbanEdited, assignee:kanban.assignee.id}
		);
		kanban = kanbanEdited
		statusMessageFormatter(res, json);
	}
	
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
	{/if}
</li>

{#if kanban.id === selectedEntry}
	<Modal bind:open={openModal}>
		<TextInput slot="header" bind:value={kanbanEdited.title} label=''/>
		<TextArea slot="body" bind:value={kanbanEdited.description} label=''/>
		<ButtonPrimary slot="footer" action={updateKanban}>Update Kanban Entry</ButtonPrimary>
		<!-- <div slot="header" class="p-4 w-[800px]">{kanban.title}</div> -->
		<!-- <div slot="body" class="p-5 ">
			{kanban.description}
		</div> -->
	</Modal>
{/if}

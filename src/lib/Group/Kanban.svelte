<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons/faArrowLeft';
	import { faArrowRight } from '@fortawesome/free-solid-svg-icons/faArrowRight';
	import Modal from '$lib/Generic/Modal.svelte';
	import type { kanban } from './interface';
	import { page } from '$app/stores';
	import { fade } from 'svelte/transition';

	onMount(() => {
		// getKanbanEntries();
		// createKanbanEntry();
		// updateKanbanEntry();
		// deleteKanbanEntry();
	});

	const createKanbanEntry = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/kanban/create`,
			{
				assignee: 2,
				description: 'This field is required.',
				tag: 2,
				title: 'I am an impostor'
			}
		);
		statusMessageFormatter(res, json);
	};

	const updateKanbanEntry = async () => {
		const { res, json } = await fetchRequest('POST', 'group/4/kanban/4/update', {
			description: 'haiii',
			assignee: 2,
			tag: 2,
			title: 'No sussy baka'
		});
		statusMessageFormatter(res, json);
	};

	const deleteKanbanEntry = async () => {
		const { res, json } = await fetchRequest('POST', 'group/4/kanban/1/delete', {
			kanban_entry_id: 1
		});
		statusMessageFormatter(res, json);
	};

	const getKanbanEntries = async () => {
		const { res, json } = await fetchRequest('GET', 'home/kanban');
		statusMessageFormatter(res, json);
		kanbanEntries = json.results;
		return json.results;
	};

	const tags = ['Backlog', 'To Do', 'In Progress', 'Evaluation', 'Done'];
	let kanbanEntries: kanban[] = [];

	const handleUpdateKanban = async (kanban: any) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/kanban/${kanban.id}/update`,
			kanban
		);
		statusMessageFormatter(res, json);
	};

	let openModal = false;
	let promise = getKanbanEntries();
</script>

<div class="bg-white p-6">
	<div class="flex justify-between">
		<!-- {#await promise}
			<div>Loading...</div>
		{:then kanbanEntries} -->
		{#each tags as tag, i}
			<div>
				<span class="font-bold text-xl">{tag}</span>
				<ul class="flex flex-col mt-2">
					{#each kanbanEntries as kanban}
						{#if kanban.tag === i}
							<li class="border border-gray-200 hover:bg-gray-200 p-2" in:fade>
								<div on:click={() => (openModal = true)} class="cursor-pointer hover:underline">
									<div>{kanban.title}</div>
								</div>
								<div class="flex justify-between mt-2">
									<div
										class="cursor-pointer"
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
										class="cursor-pointer"
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
</div>

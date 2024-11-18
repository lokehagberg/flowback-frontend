<script lang="ts">
	import KanbanEntry from './KanbanEntry.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { _ } from 'svelte-i18n';
	import type { GroupUser, kanban } from '../interface';
	import { page } from '$app/stores';
	import Button from '$lib/Generic/Button.svelte';
	import { onDestroy, onMount } from 'svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { kanban as kanbanLimit } from '../../Generic/APILimits.json';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import CreateKanbanEntry from './CreateKanbanEntry.svelte';
	import type { WorkGroup } from '../WorkingGroups/interface';

	const tags = ['', 'Backlog', 'To do', 'Current', 'Evaluation', 'Done'];
	//TODO: the interfaces "kanban" and "KanbanEntry" are equivalent, make them use the same interface.
	let kanbanEntries: kanban[] = [],
		assignee: number | null = null,
		users: GroupUser[] = [],
		status: StatusMessageInfo,
		poppup: poppup,
		interval: any,
		open = false,
		numberOfOpen = 0,
		filter: { assignee: number | null } = { assignee: null },
		workGroups: WorkGroup[] = [];

	export let type: 'home' | 'group',
		Class = '';

	const changeNumberOfOpen = (addOrSub: 'Addition' | 'Subtraction') => {
		if (numberOfOpen < 0) numberOfOpen = 0;

		if (addOrSub === 'Addition') numberOfOpen += 1;
		if (addOrSub === 'Subtraction') numberOfOpen -= 1;
	};

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
		const { res, json } = await fetchRequest(
			'GET',
			`user/kanban/entry/list?limit=${kanbanLimit}&order_by=priority_desc`
		);

		if (!res.ok) status = statusMessageFormatter(res, json);
		kanbanEntries = json.results;
	};

	const getGroupUsers = async () => {
		let api = `group/${$page.params.groupId}/users?limit=${kanbanLimit}`;

		const { json } = await fetchRequest('GET', api);
		users = json.results;
		if (!assignee) assignee = users[0]?.user.id;
	};

	const getWorkGroups = async () => {
		const { res, json } = await fetchRequest('GET', `group/${$page.params.groupId}/list`);

		if (!res.ok) return;
		workGroups = json.results;
	};

	const removeKanbanEntry = (id: number) => {
		kanbanEntries = kanbanEntries.filter((entry) => entry.id !== id);
	};

	onMount(() => {
		assignee = Number(localStorage.getItem('userId')) || 1;
		getKanbanEntries();
		getWorkGroups();

		interval = setInterval(() => {
			if (numberOfOpen === 0) getKanbanEntries();
		}, 20000);
	});

	onDestroy(() => {
		clearInterval(interval);
	});
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
					class="bg-white inline-block min-w-[120px] max-w-[500px] w-1/5 p-2 m-1 dark:bg-darkbackground dark:text-darkmodeText border-gray-200 rounded-xl"
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

<CreateKanbanEntry bind:open {type} bind:kanbanEntries {users} {workGroups} />

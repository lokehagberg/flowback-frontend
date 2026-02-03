<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import Modal from '$lib/Generic/Modal.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import type { Group } from '$lib/Group/interface';
	import type { User } from '$lib/User/interfaces';
	import Button from '$lib/Generic/Button.svelte';
	import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';
	import { onMount } from 'svelte';
	import { groupStore, workgroupStore } from '$lib/Group/Kanban/Kanban';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';

	interface Props {
		groupIds: number[];
		workgroupIds: number[];
		userChecked: boolean;
		assigneeId?: number;
	}

	let {
		groupIds = $bindable(),
		workgroupIds = $bindable(),
		userChecked = $bindable(),
		assigneeId = $bindable()
	}: Props = $props();

	let openFilter = $state(false),
		groups: Group[] = $state([]),
		workgroups: WorkGroup[] = $state([]),
		users: User[] = $state([]);

	const getGroups = async () => {
		// let urlFilter = 'joined=true';
		let urlFilter = '';
		// loading = true;
		const { res, json } = await fetchRequest(
			'GET',
			`group/list?limit=50&${urlFilter}&joined=true`
		);
		// loading = false;

		if (!res.ok) return;

		groups = json?.results;
		groupStore.set(groups);
	};

	const getWorkgroups = async () => {
		// Creates a list of promises to fetch workgroups for each groupId
		const workgroupsPromise = groups.map((g) =>
			fetchRequest('GET', `group/${g.id}/list`)
		);
		let hasError = false;

		// Fetches all workgroups concurrently and makes sure all events are in one neat array
		workgroups = (await Promise.all(workgroupsPromise))
			.map(({ res, json }) => {
				if (!res.ok) {
					hasError = true;
					return [];
				} else return json.results;
			})
			.flat(1);

		// If any of the workgroup fetches failed, we set an error message
		if (hasError)
			ErrorHandlerStore.set({
				message: 'Failed to fetch atleast some workgroups',
				success: false
			});

		$workgroupStore = workgroups;
	};

	const getUsers = async () => {
		const { res, json } = await fetchRequest('GET', 'users?limit=1000');

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to fetch users',
				success: false
			});
			return;
		}

		users = json?.results ?? [];
	};

	onMount(async () => {
		await getGroups();
		await getWorkgroups();
		await getUsers();
	});

	$inspect(workgroups);
</script>

<Modal bind:open={openFilter} Class="max-w-[600px]">
	<div slot="body" class="flex flex-col items-start">
		<div class="flex">
			<input type="checkbox" bind:checked={userChecked} value />
			<span class="ml-2">{$_('User Schedule')}</span>
		</div>
		{#each groups as group}
			<div class="flex">
				<input
					type="checkbox"
					onchange={() => {
						if (groupIds.includes(group.id)) {
							groupIds = groupIds.filter((id) => id !== group.id);
						} else {
							groupIds = [...groupIds, group.id];
						}
					}}
					checked={groupIds.includes(group.id)}
				/>
				<span class="ml-2 break-all">{group.name}</span>
			</div>

			{#each workgroups.filter((w) => w.group_id === group.id) as workgroup}
				<div class="flex ml-8">
					<input
						type="checkbox"
						onchange={() => {
							if (workgroupIds.includes(workgroup.id)) {
								workgroupIds = workgroupIds.filter((id) => id !== workgroup.id);
							} else {
								workgroupIds = [...workgroupIds, workgroup.id];
							}
						}}
						checked={workgroupIds.includes(workgroup.id)}
					/>
					<span class="ml-2">{workgroup.name}</span>
				</div>
			{/each}
		{/each}

		<div class="mt-4 w-full">
			<RadioButtons2
				name="assignee"
				label="Assignee"
				labels={['Anyone', ...users.map((u) => u.username)]}
				values={[0, ...users.map((u) => u.id)]}
				bind:value={assigneeId}
				onChange={(v: String) => (assigneeId = Number(v))}
			/>
		</div>
	</div>
</Modal>

<Button onClick={() => (openFilter = true)}>Open Advanced Filter</Button>

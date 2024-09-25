<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { WorkingGroup } from '../interface';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';

	let workingGroups: WorkingGroup[] = [
		{ name: 'hi :3', isMember: false, invite: false, members: 8 },
		{ name: 'exclusive group', isMember: false, invite: true, members: 8 },
		{ name: 'dont leave me!', isMember: true, invite: true, members: 9 }
	];

	const getWorkingGroupList = async () => {
		const { res, json } = await fetchRequest('GET', `group/${$page.params.groupId}/list`);
	};

	const createWorkingGroup = async () => {
		const { res, json } = await fetchRequest('POST', `group/${$page.params.groupId}/workgroup/create`, {
			name: 'hi',
			direct_join: false
		});
	};

	onMount(() => {
		createWorkingGroup()
		getWorkingGroupList();

	})
</script>

{#each workingGroups as workingGroup}
	<div class="bg-white dark:bg-darkobject w-full p-6 mb-6 flex justify-between items-center">
		<span class="text-primary w-[20%]">{workingGroup.name}</span>
		<span class="text-gray-500 text-sm">Members: {workingGroup.members} </span>

		{#if workingGroup.isMember}
			<Button buttonStyle="warning" Class="px-3 py-1 w-[20%]">Leave</Button>
		{:else if workingGroup.invite}
			<Button buttonStyle="primary-light" Class="px-3 py-1 w-[20%]">Ask to Join</Button>
		{:else}
			<Button buttonStyle="primary-light" Class="px-3 py-1 w-[20%]">Join</Button>
		{/if}
	</div>
{/each}

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { WorkingGroup as WorkingGroupType } from '../interface';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import WorkingGroup from './WorkingGroup.svelte';

	let workingGroups: WorkingGroupType[] = [],
		poppup: poppup;

	const getWorkingGroupList = async () => {
		const { res, json } = await fetchRequest('GET', `group/${$page.params.groupId}/list`);

		if (!res.ok) {
			poppup = { message: 'Could not fetch working groups', success: false };
			return;
		}

		workingGroups = json.results;
	};

	const createWorkingGroup = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/workgroup/create`,
			{
				name: 'hi',
				direct_join: false
			}
		);

		if (!res.ok) {
			poppup = { message: 'Failed to create working group', success: false };
			return;
		}
	};

	onMount(() => {
		createWorkingGroup();
		getWorkingGroupList();
	});
</script>

{#each workingGroups as workingGroup}
	<WorkingGroup bind:workingGroup />
{/each}

<Poppup bind:poppup />

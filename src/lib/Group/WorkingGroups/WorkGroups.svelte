<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { WorkGroup as WorkingGroupType } from './interface';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import WorkingGroup from './WorkGroup.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';

	let workGroups: WorkingGroupType[] = [],
		workGroupEdit: WorkingGroupType = { direct_join: false, members: null, name: '', id: 0 },
		poppup: poppup,
		open = false;

	const getWorkingGroupList = async () => {
		const { res, json } = await fetchRequest('GET', `group/${$page.params.groupId}/list?limit=100`);

		if (!res.ok) {
			poppup = { message: 'Could not fetch working groups', success: false };
			return;
		}

		workGroups = json.results;
	};

	const createWorkingGroup = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/workgroup/create`,
			workGroupEdit
		);

		if (!res.ok) {
			poppup = { message: 'Failed to create working group', success: false };
			return;
		}
	};

	onMount(() => {
		getWorkingGroupList();
	});
</script>

{#each workGroups as workingGroup}
	<WorkingGroup bind:workGroup={workingGroup} />
{/each}

<Poppup bind:poppup />

<Button action={() => (open = true)}>Create Working Group</Button>

<Modal bind:open>
	<div slot="header"><h1>Create a Work Group</h1></div>
	<form slot="body" on:submit|preventDefault={createWorkingGroup}>
		<TextInput label="Name" required bind:value={workGroupEdit.name} />
		<RadioButtons2
			bind:value={workGroupEdit.direct_join}
			values={[true, false]}
			labels={['Yes', 'No']}
			label="Direct Join?"
			name="direct_join"
		/>
		<Button Class="px-2" type="submit">Create</Button>
	</form>
</Modal>

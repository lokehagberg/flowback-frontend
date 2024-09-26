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
		open = false,
		search: string;

	const getWorkingGroupList = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/list?limit=100&name__icontains=${search}`
		);

		if (!res.ok) {
			poppup = { message: 'Could not fetch work groups', success: false };
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
			poppup = { message: 'Failed to create work group', success: false };
			return;
		}

		await getWorkingGroupList();
		open = false;
	};

	onMount(() => {
		getWorkingGroupList();
	});
</script>

<div class="bg-white p-6 shadow rounded mb-4">
	<TextInput
		label=""
		placeholder="search work group"
		bind:value={search}
		onInput={getWorkingGroupList}
	/>
</div>

<Button action={() => (open = true)} Class="p-2">Create Work Group</Button>

<div class="flex flex-col gap-4 mt-4">
	{#each workGroups as workingGroup}
		<WorkingGroup bind:workGroup={workingGroup} />
	{/each}
</div>

<Poppup bind:poppup />

<Modal bind:open>
	<div slot="header" class="w-full"><span>Create a Work Group</span></div>
	<form slot="body" class="w-full" on:submit|preventDefault={createWorkingGroup}>
		<TextInput label="Name" required bind:value={workGroupEdit.name} />

		<RadioButtons2
			bind:value={workGroupEdit.direct_join}
			values={[true, false]}
			labels={['Yes', 'No']}
			label="Direct Join?"
			name="direct_join"
		/>

		<button type="submit">hi</button>

		<Button Class="px-2" type="submit">Create</Button>
	</form>
</Modal>

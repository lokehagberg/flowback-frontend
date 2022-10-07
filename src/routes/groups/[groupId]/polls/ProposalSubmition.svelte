<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { page } from '$app/stores';

	let title: string;
	let description: string;

	const addProposal = () => {
		fetchRequest(
			'POST',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposal/create`,
			{
				title,
				description
			}
		);
	};
</script>

<form on:submit|preventDefault={addProposal} class="p-4 border border-gray-200 rounded mt-4">
	<h1 class="text-left text-2xl mb-4">Create a Proposal</h1>
	<TextInput label="Title" />
	<TextArea Class="mt-4" label="Description" />
	<ButtonPrimary type="submit" />
</form>

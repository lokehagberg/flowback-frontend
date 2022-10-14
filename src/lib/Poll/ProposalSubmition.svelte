<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { page } from '$app/stores';
	import type { proposal } from '$lib/typescriptexperiments';
	import { _ } from 'svelte-i18n';
	
	let title: string;
	let description: string;
	export let abstained:proposal[];

	const addProposal = async () => {
		const { json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposal/create`,
			{
				title,
				description
			}
		);

		abstained.push({
			title,
			description,
			id:json
		})

		abstained = abstained

	};
</script>

<form on:submit|preventDefault={addProposal} class="p-4 border border-gray-200 rounded">
	<h1 class="text-left text-2xl">{$_("Create a Proposal")}</h1>
	<TextInput label="Title" bind:value={title}/>
	<TextArea Class="mt-4" label="Description" bind:value={description}/>
	<ButtonPrimary type="submit" />
</form>

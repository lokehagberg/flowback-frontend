<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { page } from '$app/stores';
	import type { proposal } from '$lib/typescriptexperiments';
	import { _ } from 'svelte-i18n';
	import Loader from '$lib/Generic/Loader.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';

	let title: string,
		description: string,
		loading = false,
		status: StatusMessageInfo;
	export let abstained: proposal[];

	const addProposal = async () => {
		loading = true;
		const { res, json } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/poll/${$page.params.pollId}/proposal/create`,
			{
				title,
				description
			}
		);

		console.log(res, json, "RESJSON")

		if (res.ok) {
			status = { message: 'Lyckades skapa förslag', success: true };
			abstained.push({
				title,
				description,
				id: json
			});

			abstained = abstained;
		} else status = { message: 'Misslyckades med att skapa förslag', success: true };

		loading = false;
	};
</script>

<form on:submit|preventDefault={addProposal} class="p-4 border border-gray-200 rounded">
	<Loader bind:loading>
		<h1 class="text-left text-2xl">{$_('Create a Proposal')}</h1>
		<TextInput label="Title" bind:value={title} />
		<TextArea Class="mt-4" label="Description" bind:value={description} />
		<StatusMessage bind:status />
		<ButtonPrimary type="submit" label="Lägg till" />
	</Loader>
</form>

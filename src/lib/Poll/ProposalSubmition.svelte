<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { page } from '$app/stores';
	import type { proposal } from '$lib/typescriptexperiments';
	import { _ } from 'svelte-i18n';
	import Loader from '$lib/Generic/Loader.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';

	let title: string,
		description: string,
		loading = false,
		status: StatusMessageInfo,
		show = false;
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

		statusMessageFormatter(res, json);

		if (res.ok) {
			show = true
			setTimeout(() => {
				show = false
			}, 3000);

			abstained.push({
				title,
				description,
				id: json
			});

			abstained = abstained;
			title = '';
			description = '';
		}

		loading = false;
	};
</script>

<SuccessPoppup bind:show />
<form on:submit|preventDefault={addProposal} class="p-4 border border-gray-200 rounded">
	<Loader bind:loading>
		<h1 class="text-left text-2xl">{$_('Create a Proposal')}</h1>
		<TextInput required label="Title" bind:value={title} />
		<TextArea Class="mt-4" label="Description" bind:value={description} />
		<StatusMessage bind:status />
		<Button type="submit" label="Lägg till" />
	</Loader>
</form>

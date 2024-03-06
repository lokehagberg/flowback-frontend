<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { page } from '$app/stores';
	import { _ } from 'svelte-i18n';
	import Loader from '$lib/Generic/Loader.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import type { proposal } from './interface';

	let title: string,
		description: string,
		loading = false,
		status: StatusMessageInfo,
		show = false;

	export let proposals: proposal[];

	const addProposal = async () => {
		loading = true;
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/proposal/create`,
			{
				title,
				description
			}
		);

		const id = json;
		statusMessageFormatter(res, json);

		if (res.ok) {
			show = true;

			let created_by = await getUserInfo();
			proposals.push({
				title,
				description,
				id,
				created_by,
				poll: Number($page.params.pollId)
			});

			proposals = proposals;
			title = '';
			description = '';
		}

		loading = false;
	};

	//TODO: Multiple places in the codebase uses this rather than local storage for group-user info
	const getUserInfo = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?user_id=${Number(localStorage.getItem('userId'))}`
		);
		return json.results[0].id;
	};
</script>

<SuccessPoppup bind:show />
<form on:submit|preventDefault={addProposal} class="p-4 border border-gray-200 dark:border-gray-500 rounded">
	<Loader bind:loading>
		<h1 class="text-left text-2xl">{$_('Create a Proposal')}</h1>
		<TextInput required label="Title" bind:value={title} />
		<TextArea Class="mt-4" label="Description" bind:value={description} />
		<StatusMessage bind:status />
		<Button type="submit" label="Add" />
	</Loader>
</form>

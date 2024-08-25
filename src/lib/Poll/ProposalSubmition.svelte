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
	import type { poll, proposal } from './interface';
	import { getProposals } from '$lib/Generic/AI';
	import { createProposal } from '$lib/Blockchain/javascript/pollsBlockchain';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import FileUploads from '$lib/Generic/FileUploads.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import { env } from "$env/dynamic/public";


	let title: string,
		description: string,
		loading = false,
		status: StatusMessageInfo,
		poppup: poppup = { message: '', success: true, show: true },
		show = false,
		blockchain = true,
		images: File[];

	export let proposals: proposal[], poll: poll;

	const addProposal = async () => {
	
		loading = true;	console.log("Hello?");

		let blockchain_id;
		if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE' && blockchain && poll.blockchain_id)
			blockchain_id = await createProposal(poll.blockchain_id, title);

		let proposal: any = { title, description };
		if (blockchain_id) proposal.blockchain_id = blockchain_id;

		const formData = new FormData();
		formData.append('title', title);
		formData.append('description', description);

		images.forEach((image) => {
			formData.append('attachments', image);
		});

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/proposal/create`,
			formData,
			true,
			false
		);

		const id = json;
		statusMessageFormatter(res, id);

		if (!res.ok) return;

		poppup = { message: 'Successfully added proposal', success: true };

		let created_by = await getUserInfo();
		loading = false;

		proposals.push({
			title,
			description,
			id,
			created_by,
			poll: Number($page.params.pollId),
			attachments: []
		});
		proposals = proposals;

		title = '';
		description = '';
		
	};

	//TODO: Multiple places in the codebase uses this rather than local storage for group-user info
	const getUserInfo = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?user_id=${Number(localStorage.getItem('userId'))}`
		);
		if (!res.ok) return;
		return json.results[0].id;
	};
</script>

<!-- <SuccessPoppup bind:show /> -->
<Poppup bind:poppup />
<form on:submit|preventDefault={addProposal} class=" h-full dark:border-gray-500 rounded">
	<Loader bind:loading>
		<span class="block text-left text-md text-primary font-bold">{$_('Create a Proposal')}</span>
		<TextInput required label="Title" bind:value={title} />
		<TextArea Class="mt-4" label="Description" bind:value={description} />
		{#if env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE'}
			<RadioButtons bind:Yes={blockchain} label="Push to Blockchain" />
		{/if}
		<FileUploads bind:images />

		<StatusMessage bind:status />
		<Button
			buttonStyle="primary-light"
			Class="absolute bottom-0 w-full"
			type="submit"
			label="Add Proposal"
		/>
		{#if env.PUBLIC_FLOWBACK_AI_MODULE === 'TRUE'}
			<Button Class="pr-3 pl-3" action={async () => (title = await getProposals(poll.title))}
				>{$_('Generate with the help of AI')}</Button
			>
		{/if}
	</Loader>
</form>

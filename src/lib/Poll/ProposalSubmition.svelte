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
	import { proposalCreate as proposalCreateBlockchain } from '$lib/Blockchain_v1_Ethereum/javascript/pollsBlockchain';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import FileUploads from '$lib/Generic/FileUploads.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import { env } from '$env/dynamic/public';

	export let proposals: proposal[] = [],
		poll: poll,
		displayForm: boolean;

	let title: string,
		description: string,
		loading = false,
		status: StatusMessageInfo,
		poppup: poppup = { message: '', success: true, show: true },
		blockchain = true,
		images: File[];

	const proposalCreate = async () => {
		if (loading === true) return;
		loading = true;

		let blockchain_id;
		if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE' && blockchain && poll.blockchain_id)
			blockchain_id = await proposalCreateBlockchain(poll.blockchain_id, title);

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

	const cancelSubmission = () => {
		displayForm = false;
		title = '';
		description = '';
	};
</script>

<form on:submit|preventDefault={proposalCreate} class="h-full dark:border-gray-500 rounded p-2">
	<Loader bind:loading>
		<div class="flex flex-col space-y-2">
			<span class="block text-left text-md text-primary dark:text-secondary font-semibold"
				>{$_('Create a Proposal')}</span
			>
			<TextInput required label="Title" bind:value={title} />
			<TextArea
				Class="mt-4"
				inputClass="whitespace-pre-wrap"
				areaClass="max-h-[12rem] resize-y"
				label="Description"
				bind:value={description}
			/>
		</div>
		{#if env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE'}
			<RadioButtons bind:Yes={blockchain} label="Push to Blockchain" />
		{/if}

		<FileUploads bind:files={images} />
		<StatusMessage bind:status />

		<Button
			buttonStyle="primary-light"
			Class="absolute bottom-0 w-[49%]"
			type="submit"
			label="Confirm"
		/>

		<Button
			bind:disabled={loading}
			buttonStyle="warning-light"
			Class="absolute bottom-0 right-0 w-[49%]"
			type="button"
			label="Cancel"
			onClick={cancelSubmission}
		/>

		{#if env.PUBLIC_FLOWBACK_AI_MODULE === 'TRUE'}
			<Button
				bind:disabled={loading}
				Class="pr-3 pl-3"
				onClick={async () => (title = await getProposals(poll.title))}
				>{$_('Generate with the help of AI')}</Button
			>
		{/if}
	</Loader>
</form>

<Poppup bind:poppup />

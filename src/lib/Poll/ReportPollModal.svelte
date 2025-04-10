<script lang="ts">
	import { goto } from '$app/navigation';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';

	export let reportPollModalShow = false,
		pollId: string|number;
		
	let title: string,
		description: string;

	const reportPoll = async () => {
		let _api = 'report/create';

		let data = {
			title: title,
			description: description
		};

		const { res, json } = await fetchRequest('POST', _api, data);

		if (!res.ok) {
			return;
		}
        reportPollModalShow = false;
	};
</script>

<Modal bind:open={reportPollModalShow}>
	<div slot="header">{$_('Report Poll')}</div>
	<div class="flex flex-col gap-3" slot="body">
		<TextInput inputClass="bg-white" required label="Title" bind:value={title} />
		<TextArea label="Description" required bind:value={description} inputClass="whitespace-pre-wrap" />
	</div>
	<div slot="footer">
		<div class="flex justify-center gap-2">
			<Button onClick={reportPoll} Class="bg-red-500 w-1/2">{$_('Report')}</Button><Button
				onClick={() => (reportPollModalShow = false)}
				Class="bg-gray-400 w-1/2">{$_('Cancel')}</Button
			>
		</div>
	</div>
</Modal>

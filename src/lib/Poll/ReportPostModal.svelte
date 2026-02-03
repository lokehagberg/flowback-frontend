<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Modal from '$lib/Generic/Modal.svelte';
	import { _ } from 'svelte-i18n';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import Loader from '$lib/Generic/Loader.svelte';

	export let reportModalShow = false,
		post_type: 'poll' | 'thread' = 'poll',
		group_id: string | number = '',
		post_id: string | number = '',
		post_title: string = '',
		post_description: string = '';

	let title: string,
		description: string,
		loading = false;

	const reportPoll = async () => {
		loading = true;
		let _api = 'report/create';

		let data = {
			title,
			description,
			post_type,
			post_id,
			group_id,
			post_title,
			post_description
		};

		if (description === '') {
			ErrorHandlerStore.set({
				message: 'Description is required',
				success: false
			});
			loading = false;
			return;
		}

		const { res, json } = await fetchRequest('POST', _api, data);

		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'An error occurred while reporting the poll.',
				success: false
			});
			return;
		}

		ErrorHandlerStore.set({
			message:
				post_type === 'poll'
					? 'Poll reported successfully.'
					: 'Thread reported successfully.',
			success: true
		});
		reportModalShow = false;
		title = '';
		description = '';
	};
</script>

<Modal
	bind:open={reportModalShow}
	Class="max-w-[500px]"
	buttons={[
		{ label: 'Report', type: 'warning', onClick: reportPoll },
		{
			label: 'Cancel',
			type: 'default',
			onClick: () => (reportModalShow = false)
		}
	]}
>
	>
	<div slot="header">
		{post_type === 'poll' ? $_('Report Poll') : $_('Report Thread')}
	</div>
	<div class="flex flex-col gap-3" slot="body">
		<Loader bind:loading>
			<TextInput
				inputClass="bg-white"
				required
				label="Title"
				bind:value={title}
			/>

			<TextArea
				label="Description"
				required
				bind:value={description}
				inputClass="whitespace-pre-wrap"
				id="report-description"
			/>
		</Loader>
	</div>
	<!-- <div slot="footer">
		<div class="flex justify-center gap-2">
			<Button onClick={reportPoll} type="submit" Class="bg-red-500 w-1/2">{$_('Report')}</Button
			><Button onClick={() => (reportModalShow = false)} Class="bg-gray-400 w-1/2"
				>{$_('Cancel')}</Button
			>
		</div>
	</div> -->
</Modal>

<script lang="ts">
	import { goto } from '$app/navigation';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';

	export let reportPollModalShow = false,
		pollId: string|number,
    message: string;

	const reportPoll = async () => {
		let _api = 'report/create';

		let data = {
			title: 'Report Poll',
			description: message || 'Report Poll'
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
	<div slot="body">
		{$_('Are you sure you want to report this poll?')}
	</div>
	<div slot="footer">
		<div class="flex justify-center gap-2">
			<Button onClick={reportPoll} Class="bg-red-500 w-1/2">{$_('Yes')}</Button><Button
				onClick={() => (reportPollModalShow = false)}
				Class="bg-gray-400 w-1/2">{$_('Cancel')}</Button
			>
		</div>
	</div>
</Modal>

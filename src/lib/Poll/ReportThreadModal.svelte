<script lang="ts">
	import { goto } from '$app/navigation';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';

	export let reportThreadModalShow = false,
		threadId: string|number,
    message: string;

	const reportThread = async () => {
		let _api = 'report/create';

		let data = {
			title: 'Report Thread',
			description: message || 'Report Thread'
		};

		const { res, json } = await fetchRequest('POST', _api, data);

		if (!res.ok) {
			return;
		}
    reportThreadModalShow = false;
	};
</script>

<Modal bind:open={reportThreadModalShow}>
	<div slot="header">{$_('Report Thread')}</div>
	<div slot="body">
		{$_('Are you sure you want to report this thread?')}
	</div>
	<div slot="footer">
		<div class="flex justify-center gap-2">
			<Button onClick={reportThread} Class="bg-red-500 w-1/2">{$_('Yes')}</Button><Button
				onClick={() => (reportThreadModalShow = false)}
				Class="bg-gray-400 w-1/2">{$_('Cancel')}</Button
			>
		</div>
	</div>
</Modal>

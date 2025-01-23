<script lang="ts">
	import { goto } from '$app/navigation';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';

	export let deletePollModalShow = false,
		pollId: string|number;

	const deletePoll = async () => {
		const { res, json } = await fetchRequest('POST', `group/poll/${pollId}/delete`);
        if (!res.ok) return;

		goto(`/groups/${$page.params.groupId}`);
        deletePollModalShow = false;
	};
</script>

<Modal bind:open={deletePollModalShow}>
	<div slot="header">{$_('Deleting Poll')}</div>
	<div slot="body">
		{$_('Are you sure you want to delete this poll?')}
	</div>
	<div slot="footer">
		<div class="flex justify-center gap-2">
			<Button action={deletePoll} Class="bg-red-500 w-1/2">{$_('Yes')}</Button><Button
				action={() => (deletePollModalShow = false)}
				Class="bg-gray-400 w-1/2">{$_('Cancel')}</Button
			>
		</div>
	</div>
</Modal>

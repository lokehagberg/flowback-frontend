<script lang="ts">
	import { goto } from '$app/navigation';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';

	export let deletePollModalShow = false;

	const deletePoll = async () => {
		const { res, json } = await fetchRequest('POST', `group/poll/${$page.params.pollId}/delete`);
		if (res.ok) goto(`/groups/${$page.params.groupId}`);
	};
</script>

<Modal bind:open={deletePollModalShow}>
	<div slot="header">{$_('Deleting Poll')}</div>
	<div slot="body">
		{$_('Are you sure you want to delete this poll?')}
	</div>
	<div slot="footer">
		<div class="flex justify-center gap-16">
			<Button action={deletePoll} Class="bg-red-500">{$_('Yes')}</Button><Button
				action={() => (deletePollModalShow = false)}
				Class="bg-gray-400 w-1/2">{$_('Cancel')}</Button
			>
		</div>
	</div>
</Modal>

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { _ } from 'svelte-i18n';

	export let creatingGroup: boolean,
		groupMembers: any[] = [];

	let name = '';

	const groupChatCreate = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`user/chat?target_user_ids=${groupMembers.map((member) => member.id)}`
		);

		if (!res.ok) return;

        creatingGroup = false;
	};
</script>

<form on:submit={groupChatCreate}>
	<TextInput autofocus required bind:value={name} label="Chatgroup Name" />

	{$_('Members')}
	<div>
		{#each groupMembers as member}
			{member.name}
		{/each}
	</div>

	<Button buttonStyle="primary-light" type="submit">{$_('Confirm')}</Button>
	<Button buttonStyle="warning-light">{$_('Cancel')}</Button>
</form>

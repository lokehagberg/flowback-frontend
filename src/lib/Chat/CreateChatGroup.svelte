<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { _ } from 'svelte-i18n';
	import type { GroupMembers } from './interfaces';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';

	export let creatingGroup: boolean,
		groupMembers: GroupMembers[] = [];

	let name = '',
		poppup: poppup;

	const groupChatCreate = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`user/chat?target_user_ids=1&${groupMembers
				.map(
					(member) =>
						`target_user_ids=${member.id}`
				)
				.join('&')}`
		);

		if (!res.ok) {
			poppup = { message: 'Failed to created group chat', success: false, show: true };
			return;
		}

		//Poppup doesn't work because this goes to false
		//TODO: Redo the poppup system to have a poppup queue that's always rendered and which is accessed via svelte store
		creatingGroup = false;
		groupMembers = [];
		poppup = { message: 'Successfully created group chat', success: true, show: true };
	};

	const cancelGroupChatCreate = () => {
		creatingGroup = false;
		groupMembers = [];
	};
</script>

<form on:submit={groupChatCreate}>
	<TextInput autofocus required bind:value={name} label="Chatgroup Name" />

	{$_('Members')}
	<div>
		{#each groupMembers as member}
			{member.username}
		{/each}
	</div>

	<Button buttonStyle="primary-light" type="submit">{$_('Confirm')}</Button>
	<Button buttonStyle="warning-light" onClick={cancelGroupChatCreate}>{$_('Cancel')}</Button>
	<Poppup bind:poppup Class="z-50" />
</form>

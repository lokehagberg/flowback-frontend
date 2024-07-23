<script lang="ts">
	import {_} from 'svelte-i18n';
	import {fetchRequest} from '$lib/FetchRequest';
	import Button         from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import type {StatusMessageInfo} from '$lib/Generic/GenericFunctions';
	import StatusMessage    from '$lib/Generic/StatusMessage.svelte';
	import {statusMessageFormatter} from '$lib/Generic/StatusMessage';
	import type { Account } from './interface';
	import { goto } from '$app/navigation';

	export let open: boolean = false, account: Account;
	
	const removeAccount = async () => {
		const {res, json} = await fetchRequest(
			'POST', `ledgeraccounts/${account.id}/delete`
		);
		const status = statusMessageFormatter(res, json);
		if (res.ok)
			goto(`/accounts`);
	};
</script>
<Modal bind:open>
	<div slot="header">{$_("Removing account")}</div>
	<div slot="body">
		{console.log("account:", account),2}
		{$_("Are you sure you want to remove this account?")}
	</div>
	<div slot="footer">
		<div class="flex justify-center gap-8">
			<Button action={removeAccount} Class="bg-red-500 w-1/2">{
				$_("Remove")
			}</Button>
			<Button action={()=>open = false} Class="bg-gray-400 w-1/2">{
				$_("Cancel")
			}</Button>
		</div>
	</div>
</Modal>

<script lang="ts">
	import AccountUpdater from '$lib/Account/AccountUpdater.svelte';
	import Layout         from '$lib/Generic/Layout.svelte';
	import Loader         from '$lib/Generic/Loader.svelte';
	import StatusMessage  from '$lib/Generic/StatusMessage.svelte';
	import {fetchRequest} from '$lib/FetchRequest';
	import {_}            from 'svelte-i18n';

	const
		{statusMessageFormatter} = StatusMessage;
	let
		name : string = "",
		number : string = "",
		loading : bool = false,
		status : StatusMessageInfo;
	const addAccount = async ()=>{
		loading = true;
		const formData = new FormData();

		formData.append("account_name", name);
		formData.append("account_number", number);
		const {res, json} = await fetchRequest(
			"POST", "ledger/accounts/create",
			formData, true, false
		);
		if (!res.ok) {
			status = statusMessageFormatter(res, json);
			loading = false;
			return;
		}
		window.location.href = "/accounts";
		loading = false;
	};
</script>
<svelte:head>
	<title>Flowback: {$_("Adding an Account")}</title>
</svelte:head>
<Layout centering>
	<Loader bind:loading>
		<AccountUpdater newOne={true}/>
	</Loader>
</Layout>

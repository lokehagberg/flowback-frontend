<script lang="ts">
	import {onMount}        from 'svelte';
	import {_}              from 'svelte-i18n';
	import {fetchRequest}   from '$lib/FetchRequest';
	import AccountThumbnail from '$lib/Account/AccountThumbnail.svelte';
	import Button           from '$lib/Generic/Button.svelte';
	import type {StatusMessageInfo} from '$lib/Generic/GenericFunctions';
	import Layout           from '$lib/Generic/Layout.svelte';
	import Loader           from '$lib/Generic/Loader.svelte';
	import StatusMessage    from '$lib/Generic/StatusMessage.svelte';
	import {statusMessageFormatter} from '$lib/Generic/StatusMessage';
	let status : StatusMessageInfo;
	let loading : bool = true;
	let accounts = [];

	onMount(() => {
		loadAccounts();
	});
	const loadAccounts = async () => {
		loading = true;
		const {res, json} = await fetchRequest('GET', 'ledger/accounts');
		status = statusMessageFormatter(res, json);
		loading = false;
		if (!res.ok)
			return;
		console.log("loadAccounts:", res, json);
		accounts = json.results;
	}
</script>
<svelte:head>
	<title>Account</title>
</svelte:head>
<Layout centering={true}>
	Layout
	<Loader bind:loading>
		Loader
		<StatusMessage bind:status disableSuccess/>
		StatusMessage
		<div class="flex flex-col items-center mt-6 gap-6 mb-6 w-full">
			<Button href="accounts/add" Class="w-[40%] rounded-2xl">
				Add Account
			</Button>
			{#if !loading}
				{accounts.length} account{
					accounts.length === 1 ? "" : "s"
				}{
					accounts.length ? ":" : "."
				}
			{/if}
			<ol>{#each accounts as account}
				<li><AccountThumbnail {account}/></li>
			{/each}</ol>
		</div>
	</Loader>
</Layout>

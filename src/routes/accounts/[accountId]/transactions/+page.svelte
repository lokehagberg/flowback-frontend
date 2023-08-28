<script lang="ts">
	import {onMount}        from 'svelte';
	import Button           from '$lib/Generic/Button.svelte';
	import Layout           from '$lib/Generic/Layout.svelte';
	import Loader           from '$lib/Generic/Loader.svelte';
	import {fetchRequest}   from '$lib/FetchRequest';
	import {page}           from '$app/stores';
	import TransactionTable
		from '$lib/Account/Transaction/TransactionTable.svelte'
	import {accountsStore}  from '$lib/Account/stores';

	const
		{accountId} = $page.params;
	let
		loading: bool = true,
		aLoading: bool = true,
		tLoading: bool = true,
		aOK: bool = false,
		tOK: bool = false,
		aStatus,
		tStatus,
		account: Object = undefined,
		transactions: Array = [];
	const updateLoading = async () =>
		loading = aLoading || tLoading;
	const loadAccount = async ()=>{
		const accounts = await accountsStore.get();
		aLoading = false;
		updateLoading();
		aOK = accounts.loaded;
		aStatus = accounts.status;
		if (aOK)
			account = accounts.filter(x => x.id === +accountId)[0];
	};
	const loadTransactions = async ()=>{
		tLoading = true;
		updateLoading();
		tOK = false;
		const {res, json} = await fetchRequest(
			"GET", `ledger/accounts/${accountId}/transactions`
		);
		tOK = res.ok;
		transactions = !res.ok ?
			[] :
			json.results;
		tLoading = false;
		updateLoading();
	};
	onMount(async ()=>{
		loadAccount();
		loadTransactions();
	});
</script>
<Layout>
	<h1>Transactions</h1>
	<Loader bind:loading>
		{#if aOK && account}
			<div>
				Account: {account.account_name}
					<code>{account.account_number}</code><br/>
				Balance: {account.balance}
			</div>
		{/if}
		<Button>Record Transaction</Button>
		<div>
			<p>{#if tOK}
				{transactions.length} transactions:
			{/if}&nbsp;</p>
			<TransactionTable {transactions}/>
		</div>
	</Loader>
</Layout>

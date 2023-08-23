<script lang="ts">
	import {onMount}      from 'svelte';
	import Layout         from '$lib/Generic/Layout.svelte';
	import Loader         from '$lib/Generic/Loader.svelte';
	import {fetchRequest} from '$lib/FetchRequest';
	import {page}         from '$app/stores';

	const
		{accountId} = $page.params;
	let
		loading: bool = true,
		aLoading: bool = true,
		tLoading: bool = true,
		aOK: bool = false,
		tOK: bool = false,
		account: Object = undefined,
		transactions: Array = [];
	const updateLoading = async () =>
		loading = aLoading || tLoading;
	const loadAccount = async ()=>{
		aLoading = true;
		updateLoading();
		aOK = false;
		const {res, json} = await fetchRequest(
			"GET", "ledger/accounts"
		);
		console.log("account:", {res, json});
		aOK = res.ok;
		account = !res.ok ?
			undefined :
			json.results.filter(x => x.id === +accountId)[0];
		aLoading = false;
		updateLoading();
	}
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
	}
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
		<div>
			{#if tOK}
				{transactions.length} transactions:
			{/if}
			<table>
				{#each transactions as ta}
					<tr>,</tr>
				{/each}
			</table>
		</div>
	</Loader>
</Layout>

<script lang="ts">
	import { onMount } from 'svelte';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import TransactionTable from '$lib/Account/Transaction/TransactionTable.svelte';
	import { accountsStore } from '$lib/Account/stores';

	const { accountId } = $page.params;
	let loading: boolean = true,
		aLoading: boolean = true,
		tLoading: boolean = true,
		aOK: boolean = false,
		tOK: boolean = false,
		aStatus,
		tStatus,
		account: any | undefined = undefined,
		transactions: any[] = [];

	const updateLoading = async () => (loading = aLoading || tLoading);

	const loadAccount = async () => {
		//@ts-ignore
		const accounts = await accountsStore.get();
		aLoading = false;
		updateLoading();
		aOK = accounts.loaded;
		aStatus = accounts.status;
		if (aOK) account = accounts.filter((x: any) => x.id === +accountId)[0];
	};

	const loadTransactions = async () => {
		tLoading = true;
		updateLoading();
		tOK = false;
		const { res, json } = await fetchRequest('GET', `ledgeraccounts/${accountId}/transactions`);
		tOK = res.ok;
		transactions = !res.ok ? [] : json.results;
		tLoading = false;
		updateLoading();
	};

	const recordTransaction = async () => {
		console.log("hello?")
		loading = true;
		const { res, json } = await fetchRequest(
			'POST',
			`ledgeraccounts/${accountId}/transactions/create`,
			{
				// debit_amount: '100',
				credit_amount: '50',
				description: 'I am a coconut',
				verification_number: '11111111',
				date: '2019-08-24T14:15:22Z'
			}
		);

		loading = false;
	};

	onMount(async () => {
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
				<code>{account.account_number}</code><br />
				Balance: {account.balance}
			</div>
		{/if}
		<Button action={recordTransaction}>Record Transaction</Button>
		<div>
			<p>
				{#if tOK}
					{transactions.length} transactions:
				{/if}&nbsp;
			</p>
			<TransactionTable {transactions} />
		</div>
	</Loader>
</Layout>

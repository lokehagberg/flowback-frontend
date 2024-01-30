<script lang="ts">
	import { onMount } from 'svelte';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import TransactionTable from '$lib/Account/Transaction/TransactionTable.svelte';
	import { accountsStore } from '$lib/Account/stores';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import DateInput from 'date-picker-svelte/DateInput.svelte';

	const { accountId } = $page.params;
	let loading: boolean = true,
		aLoading: boolean = true,
		tLoading: boolean = true,
		aOK: boolean = false,
		tOK: boolean = false,
		aStatus,
		tStatus,
		account: any | undefined = undefined,
		transactions: any[] = [],
		debit_amount: string,
		credit_amount: string,
		description: string,
		verification_number: string,
		date: Date,
		open = false

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
		console.log('hello?');
		loading = true;
		const { res, json } = await fetchRequest(
			'POST',
			`ledgeraccounts/${accountId}/transactions/create`,
			{
				debit_amount,
				credit_amount,
				description,
				verification_number,
				date
			}
		);

		loading = false;
	};

	onMount(async () => {
		loadAccount();
		loadTransactions();
	});
</script>

<Layout centered>
	<Button Class="mt-6" action={() => (location.href = `/accounts`)}>Go to all accounts</Button>
	<div class="p-6 bg-white dark:bg-darkobject mt-6 shadow-lg rounded dark:text-darkmodeText">
		<Loader bind:loading>
			<h1>Transactions</h1>
			<div class="flex flex-col gap-4">
				{#if aOK && account}
					<div>
						Account: {account.account_name}
						<code>{account.account_number}</code><br />
						Balance: {account.balance}
					</div>
				{/if}
				<Button action={() => open = !open}>Record Transaction</Button>
				<div>
					<p>
						{#if tOK}
							{transactions.length} transactions:
						{/if}&nbsp;
					</p>
					<TransactionTable {transactions} />
				</div>
			</div>
		</Loader>
	</div>
</Layout>

<Modal bind:open>
	<div slot="body">
		<form>
			<div>
				<TextInput label={'debit_amount'} bind:value={debit_amount} />
			</div>
			<div>
				<TextInput label={'credit_amount'} bind:value={credit_amount} />
			</div>
			<div>
				<TextInput label={'description'} bind:value={description} />
			</div>
			<div>
				<TextInput label={'verification_number'} bind:value={verification_number} />
			</div>
			<div>
				<DateInput bind:value={date} />
			</div>
		</form>
	</div>
	<div slot="footer">
		<Button action={recordTransaction}>Create Transaction</Button>
	</div>
</Modal>

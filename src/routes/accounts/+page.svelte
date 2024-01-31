<script lang="ts">
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { accountsStore } from '$lib/Account/stores';
	import type { Transaction as TransactionType, Account } from '$lib/Account/interface';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import DateInput from 'date-picker-svelte/DateInput.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import Select from '$lib/Generic/Select.svelte';
	import Transaction from '$lib/Account/Transaction.svelte';

	let loading: boolean = true,
		transactions: TransactionType[] = [],
		status: StatusMessageInfo,
		aggregatedBalance: number = 0,
		account_id: number,
		show = false,
		newTransaction = false,
		debit_amount: string,
		credit_amount: string,
		description: string,
		verification_number: string,
		date: Date,
		account_name: string,
		account_number: string,
		accounts: Account[] = [],
		value: number;

	onMount(async () => {
		//@ts-ignore
		transactions = await accountsStore.get();

		// console.log(transactions, 'TRANS');
		// totalBalance();
		getAccounts();

		loading = false;
	});

	const totalBalance = () => {
		transactions.forEach((account) => {
			// aggregatedBalance += account.balance;
		});
	};

	const getAccounts = async () => {
		const { res, json } = await fetchRequest('GET', `ledger/account/list`);
		accounts = json.results;
		console.log(
			accounts.map((account) => account.account_name),
			'ACCOUNTING'
		);
	};

	const createTransaction = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`ledger/account/${account_id}/transactions/create`,
			{
				debit_amount,
				credit_amount,
				description,
				verification_number,
				date
			}
		);
	};

	const createAccount = async () => {
		loading = true;
		const formData = new FormData();

		// formData.append('account_name', name);
		// formData.append('account_number', number);

		const { res, json } = await fetchRequest(
			'POST',
			'ledger/account/create',
			{
				account_name,
				account_number
			},
			true,
			false
		);

		// if (!res.ok) {
		// 	status = statusMessageFormatter(res, json);
		// 	loading = false;
		// 	return;
		// }

		// window.location.href = '/accounts';
		loading = false;
	};
</script>

<svelte:head>
	<title>{$_('Accounts')}</title>
</svelte:head>
<Layout centered>
	<div class="p-6 mt-6 dark:text-darkmodeText">
		<Loader bind:loading>
			<h1>Transactions</h1>
			<Button
				action={() => {
					show = true;
					newTransaction = true;
				}}>Add Transaction</Button
			>
			<div class="grid grid-cols-8 gap-4 mt-3 bg-darkobject rounded shadow p-4">
				{#each transactions as transaction}
					<Transaction {transaction} {accounts} />
				{/each}
			</div>
		</Loader>
	</div>
</Layout>

<Modal bind:open={show}>
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
			<Select
				labels={accounts.map((account) => account.account_name)}
				values={accounts.map((account) => account.id)}
				bind:value={account_id}
				onInput={(e) => {
					//@ts-ignore
					const selectedScore = e?.target?.value;
					account_id = Number(selectedScore);
				}}
			/>
		</form>
	</div>
	<div slot="footer">
		<Button action={createTransaction}>Create Transaction</Button>
	</div>
</Modal>

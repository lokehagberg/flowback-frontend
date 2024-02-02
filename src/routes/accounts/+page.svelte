<script lang="ts">
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import type { Transaction as TransactionType, Account } from '$lib/Account/interface';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import DateInput from 'date-picker-svelte/DateInput.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import Select from '$lib/Generic/Select.svelte';
	import Transaction from '$lib/Account/Transaction.svelte';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import { formatDate } from '$lib/Generic/DateFormatter';

	let loading: boolean = true,
		transactions: TransactionType[] = [],
		status: StatusMessageInfo,
		aggregatedBalance: number = 0,
		account_id: number,
		show = false,
		show_account = false,
		show_poppup = false,
		newTransaction = false,
		showDeleteAccount = false,
		amount: number = 0,
		account_type: 'debit' | 'credit',
		description: string,
		verification_number: string,
		date: Date,
		account_name: string,
		account_number: string,
		accounts: Account[] = [],
		value: number,
		message: string,
		balance = 0;

	onMount(async () => {
		//@ts-ignore
		getAccounts();
		await getTransactions();

		// console.log(transactions, 'TRANS');
		totalBalance();

		loading = false;
	});

	const totalBalance = () => {
		balance = 0;
		transactions.forEach((account) => {
			if (account.credit_amount !== 'null') balance -= Number(account.credit_amount);
			if (account.debit_amount !== 'null') balance += Number(account.debit_amount);
		});
	};

	const getAccounts = async () => {
		loading = true;
		const { res, json } = await fetchRequest('GET', `ledger/account/list`);
		if (!res.ok) message = 'Something went wrong';
		loading = false;
		accounts = json.results;
	};

	const getTransactions = async () => {
		loading = true;
		const { res, json } = await fetchRequest('GET', 'ledger/transactions/list');
		if (!res.ok) message = 'Something went wrong';
		transactions = json.results;
		loading = false;
	};

	const createTransaction = async () => {
		loading = true;
		const { res, json } = await fetchRequest(
			'POST',
			`ledger/account/${account_id}/transactions/create`,
			{
				debit_amount: account_type === 'debit' ? amount : 0,
				credit_amount: account_type === 'credit' ? amount : 0,
				description,
				verification_number,
				date: date
			}
		);

		loading = false;

		if (!res.ok) {
			show_poppup = true;
			message = 'Something went wrong';
			return;
		} else {
			show_poppup = true;
			message = 'Successfully created transaction';
		}

		transactions.push({
			debit_amount: (account_type === 'debit' ? amount : 0).toString(),
			credit_amount: (account_type === 'credit' ? amount : 0).toString(),
			description,
			verification_number,
			date: date.toString(),
			id: '',
			account: {
				account_name: accounts.find((account) => account.id === account_id)?.account_name || '',
				account_number: accounts.find((account) => account.id === account_id)?.account_number || '',
				id: 9999999,
				//@ts-ignore
				created_by: null
			}
		});
		transactions = transactions;
	};

	const createAccount = async () => {
		loading = true;
		const formData = new FormData();

		// formData.append('account_name', name);
		// formData.append('account_number', number);

		const { res, json } = await fetchRequest('POST', 'ledger/account/create', {
			account_name,
			account_number
		});

		loading = false;

		if (!res.ok) {
			show_poppup = true;
			message = 'Something went wrong';
			return;
		} else {
			show_poppup = true;
			message = 'Successfully created account';
			accounts.push({
				//@ts-ignore
				account_name,
				account_number,
				id: json,
				created_by: undefined
			});
			accounts = accounts;
		}

		// if (!res.ok) {
		// 	status = statusMessageFormatter(res, json);
		// 	loading = false;
		// 	return;
		// }

		// window.location.href = '/accounts';
	};

	const deleteAccount = async () => {
		loading = true;
		const { res, json } = await fetchRequest('POST', `ledger/account/${account_id}/delete`);
		loading = false;

		if (!res.ok) {
			show_poppup = true;
			message = 'Something went wrong';
			return;
		} else {
			show_poppup = true;
			message = 'Successfully deleted account';
			accounts = accounts.filter((account) => account_id !== account.id);
			transactions = transactions.filter((transaction) => transaction.account.id !== account_id);
		}
	};

	$: transactions && totalBalance();
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
			<Button action={() => (show_account = true)}>Create Account</Button>
			<Button action={() => (showDeleteAccount = true)} buttonStyle="warning">Delete Account</Button
			>
			<div class="mt-5">Total Balance: {balance}</div>
			<div class="grid grid-cols-8 gap-4 mt-3 dark:bg-darkobject bg-white rounded shadow p-4">
				<div class="font-bold">Account Name</div>
				<div class="font-bold">Account Number</div>
				<div class="font-bold">Debit</div>
				<div class="font-bold">Credit</div>
				<div class="font-bold">Description</div>
				<div class="font-bold">Verification Number</div>
				<div class="font-bold">Date</div>
				<div class="ml-20 font-bold">Edit/Delete</div>

				{#each transactions as transaction}
					<Transaction bind:transaction bind:transactions bind:accounts />
				{/each}
			</div>
		</Loader>
	</div>
</Layout>

<Modal bind:open={show}>
	<div slot="header">Adding Transaction</div>
	<div slot="body" class="text-left">
		<form>
			<fieldset>
				<legend>Account type</legend>

				<div>
					<input
						type="radio"
						id="debit"
						name="account_type"
						value="debit"
						bind:group={account_type}
						checked
					/>
					<label for="debit">Debit</label>
				</div>

				<div>
					<input
						type="radio"
						id="credit"
						name="account_type"
						value="credit"
						bind:group={account_type}
					/>
					<label for="credit">Credit</label>
				</div>
			</fieldset>
			<div class="mt-3">
				<label for="amount">Amount</label>
				<div>
					<input id="amount" class="dark:bg-darkobject" type="number" bind:value={amount} min={0} />
				</div>
			</div>
			<div class="mt-3">
				<label for="verification_number">Verification number</label>
				<div>
					<input
						id="verification_number"
						class="dark:bg-darkobject"
						type="number"
						bind:value={verification_number}
						min={0}
					/>
				</div>
			</div>

			<div class="mt-3">
				<TextInput label={'Description'} bind:value={description} />
			</div>
			<div class="mt-3">
				<label for="date">Date</label>
				<DateInput bind:value={date} />
			</div>
			<div class="mt-2">
				<label for="account">Account</label>
				<div>
					<Select
						labels={accounts.map((account) => `${account.account_name} ${account.account_number}`)}
						values={accounts.map((account) => account.id)}
						bind:value={account_id}
						onInput={(e) => {
							//@ts-ignore
							const selectedScore = e?.target?.value;
							account_id = Number(selectedScore);
						}}
					/>
				</div>
			</div>
		</form>
	</div>
	<div slot="footer">
		<Button action={createTransaction}>Create Transaction</Button>
	</div>
</Modal>

<Modal bind:open={show_account}>
	<div slot="header">Creating Account</div>
	<div slot="body" class="text-left">
		<form>
			<div>
				<TextInput label={'Account name'} bind:value={account_name} />
			</div>
			<div class="mt-3">
				<label for="account_number">Account number</label>
				<div>
					<input
						id="account_number"
						class="dark:bg-darkobject"
						type="number"
						bind:value={account_number}
						min={0}
					/>
				</div>
			</div>
		</form>
	</div>
	<div slot="footer">
		<Button action={createAccount}>Create Account</Button>
	</div>
</Modal>
<SuccessPoppup bind:show={show_poppup} bind:message />

<Modal bind:open={showDeleteAccount}>
	<div slot="body">
		<div class="mt-2">
			<label for="account">Account</label>
			<div>
				<Select
					labels={accounts.map((account) => `${account.account_name} ${account.account_number}`)}
					values={accounts.map((account) => account.id)}
					bind:value={account_id}
					onInput={(e) => {
						//@ts-ignore
						const selectedScore = e?.target?.value;
						account_id = Number(selectedScore);
					}}
				/>
			</div>
		</div>
	</div>
	<div slot="footer">
		<Button action={deleteAccount} buttonStyle="warning">Delete Account</Button>
	</div>
</Modal>

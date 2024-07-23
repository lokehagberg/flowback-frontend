<script lang="ts">
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import type { Transaction as TransactionType, Account, Filter } from '$lib/Ledger/interface';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import DateInput from 'date-picker-svelte/DateInput.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import Select from '$lib/Generic/Select.svelte';
	import Transaction from '$lib/Ledger/Transaction.svelte';
	import TransactionFilter from '$lib/Ledger/TransactionFilter.svelte';
	import formatDate from '$lib/Ledger/formatDate';
	import { generateAndDownloadHTML } from '$lib/Ledger/HTML';
	import type { User } from '$lib/User/interfaces';
	import Pagination from '$lib/Generic/Pagination.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';

	let loading: boolean = true,
		transactions: TransactionType[] = [],
		account_id: number,
		openNewTransaction = false,
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
		next: string,
		prev: string,
		poppup: poppup,
		totalBalance = 0,
		filter: Filter = {
			account_ids: [],
			date_after: null,
			date_before: null,
			description: null
		},
		user: User,
		limit = 20;

	onMount(async () => {
		loading = true;
		await getAccounts();
		await getUserInfo();
		await getTransactions();
		await calculateTotalBalance();
		loading = false;
	});

	const calculateTotalBalance = () => {
		totalBalance = 0;
		transactions.forEach((account) => {
			if (account.credit_amount !== 'null') totalBalance -= Number(account.credit_amount);
			if (account.debit_amount !== 'null') totalBalance += Number(account.debit_amount);
		});
	};

	const getAccounts = async () => {
		// loading = true;
		const { res, json } = await fetchRequest('GET', `ledger/account/list`);
		if (!res.ok) {
			poppup = { message: 'Something went wrong', success: false };
			return;
		}
		// loading = false;
		accounts = json.results;
		setAccountFilter(json);
	};

	const setAccountFilter = (json: any) => {
		filter.account_ids = json.results.map((result: Account) => {
			return { id: result.id, checked: false, label: result.account_name };
		});
	};

	const getTransactions = async () => {
		// loading = true;

		let api = `ledger/transactions/list?`;

		if (filter.account_ids)
			filter.account_ids.forEach((id) => {
				if (id.checked) api += `&account_ids=${id.id}`;
			});

		if (filter.date_after !== null)
			api += `&date_after=${formatDate(filter.date_after.toString())}`;

		if (filter.date_before !== null)
			api += `&date_before=${formatDate(filter.date_before.toString())}`;

		if (filter.description !== null) api += `&description=${filter.description}`;

		api += `&limit=${limit}`;

		const { res, json } = await fetchRequest('GET', api);

		if (!res.ok) {
			poppup = { message: 'Something went wrong', success: false };
			return;
		}

		next = json.next;
		prev = json.previous;

		transactions = json.results.filter(
			(transaction: Transaction) => transaction.account.created_by.id === user?.id
		);
		// loading = false;
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
				date
			}
		);

		loading = false;

		if (!res.ok) {
			show_poppup = true;
			poppup = { message: 'Something went wrong', success: false };
			return;
		} else {
			show_poppup = true;
			poppup = { message: 'Successfully created transaction', success: true };
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

		(amount = 0), (account_type = 'debit');
		(description = ''),
			(verification_number = ''),
			(date = new Date()),
			(account_name = ''),
			(account_number = '');
	};

	const createAccount = async () => {
		loading = true;

		const { res, json } = await fetchRequest('POST', 'ledger/account/create', {
			account_name,
			account_number
		});

		loading = false;

		if (!res.ok) {
			show_poppup = true;
			poppup = { message: 'Something went wrong', success: false };
			return;
		} else {
			show_poppup = true;
			poppup = { message: 'Successfully created account', success: true };
			accounts.push({
				account_name,
				account_number,
				id: json,
				//@ts-ignore
				created_by: undefined
			});
			accounts = accounts;
		}
	};

	const deleteAccount = async () => {
		loading = true;
		const { res, json } = await fetchRequest('POST', `ledger/account/${account_id}/delete`);
		loading = false;

		if (!res.ok) {
			show_poppup = true;
			poppup = { message: 'Something went wrong', success: false };
			return;
		} else {
			show_poppup = true;
			poppup = { message: 'Successfully deleted account', success: true };
			accounts = accounts.filter((account) => account_id !== account.id);
		}
	};

	const handleSearch = async () => {
		getTransactions();
	};

	const totalAccountBalance = (
		account: Account,
		after_date: Date | null = null,
		before_date: Date | null = null
	) => {
		let total = 0;
		transactions.forEach((transaction) => {
			if (transaction.account.id !== account.id) return;
			if (after_date !== null && new Date(transaction.date) <= after_date) return;
			if (before_date !== null && new Date(transaction.date) >= before_date) return;

			total += (Number(transaction.debit_amount) || 0) - (Number(transaction.credit_amount) || 0);
		});

		return total;
	};

	// Create a function to generate HTML content
	const generateHTMLContent = () => {
		let accountHTML = ``;

		accounts.forEach((account) => {
			accountHTML += `<div>${account.account_name}</div><div>${totalAccountBalance(
				account,
				filter.date_after,
				filter.date_before
			)}</div>`;
		});

		return `
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Generated HTML</title>
        </head>
        <body>
            <h1 style="text:center">Sheet</h1>
			<div>From: ${filter.date_after ? formatDate(filter.date_after.toString()) : 'Start'}</div>
			<div>To: ${filter.date_before ? formatDate(filter.date_before.toString()) : 'End'}</div>
			<div style="display:grid; grid-template-columns:50% 50%; margin-top:10px">
				${accountHTML}
				<div style="font-weight:bold; margin-top:10px">Total balance </div> <div style="font-weight:bold; margin-top:10px"> ${totalBalance}</div>
				<div />
				</body>
        </html>
    `;
	};

	export const getUserInfo = async () => {
		const { res, json } = await fetchRequest('GET', `users?id=${localStorage.getItem('userId')}`);
		if (!res.ok) return {};
		user = json.results[0];
	};

	$: transactions && calculateTotalBalance();
</script>

<svelte:head>
	<title>{$_('Accounts')}</title>
</svelte:head>

<Layout centered>
	<div class="p-6 mt-6 dark:text-darkmodeText">
		<Loader bind:loading>
			<h1>Transactions</h1>

			<div class="mt-4">
				<div class="bg-white dark:bg-darkobject p-6">
					<div class="mb-4">Filtering</div>
					<!-- <div class="flex"> -->
					{#if !Object.values(filter).every((x) => x === null)}
						<Button
							action={() => {
								//@ts-ignore
								for (const filt in filter) {
									//@ts-ignore
									if (filt !== 'account_ids') filter[filt] = null;
									else getAccounts();
								}
								getTransactions();

								filter.account_ids.forEach((account) => {
									const acc = document.querySelector(`#input-${account.id}`);
									//@ts-ignore
									acc.checked = false;
								});
							}}>Clear Filter</Button
						>
					{/if}
					<TransactionFilter bind:filter {handleSearch} bind:accounts />
					<!-- </div> -->
				</div>
				<div class="bg-white dark:bg-darkobject p-6 mt-6">
					<Button
						action={() => {
							openNewTransaction = true;
							newTransaction = true;
						}}>Add Transaction</Button
					>
					<Button action={() => (show_account = true)}>Create Account</Button>
					<Button action={() => (showDeleteAccount = true)}>Delete An Account</Button>
					<Button action={() => generateAndDownloadHTML(generateHTMLContent)}
						>Generate Printable HTML file {filter.date_before !== null || filter.date_after !== null
							? 'between selected dates'
							: ''}</Button
					>
					<div class="mt-4 flex gap-2">
						Show on page:
						<Select
							labels={['20', '50', '100', 'All']}
							values={[20, 50, 100, 10000]}
							bind:value={limit}
							onInput={(e) => {
								const selectedOptions = Array.from(
									//@ts-ignore
									e.target?.selectedOptions,
									//@ts-ignore
									(option) => option.value
								);
								//@ts-ignore
								limit = selectedOptions;
								getTransactions();
							}}
						/>
					</div>
				</div>
			</div>

			<div class="mt-5">Total Balance: {totalBalance}</div>
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

				<Pagination bind:iterable={transactions} bind:next bind:prev />
			</div>
		</Loader>
	</div>
</Layout>

<Modal bind:open={openNewTransaction}>
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

<Poppup bind:poppup />

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

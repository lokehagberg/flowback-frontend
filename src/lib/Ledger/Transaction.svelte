<script lang="ts">
	import type { Transaction } from './interface';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faScrewdriver, faTrash } from '@fortawesome/free-solid-svg-icons';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import type { Account } from '$lib/Ledger/interface';
	import Modal from '$lib/Generic/Modal.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import DateInput from 'date-picker-svelte/DateInput.svelte';
	import { deepCopy } from 'ethers/lib/utils';
	import formatDate from './formatDate';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	// import { formatDate } from '$lib/Generic/DateFormatter';

	export let transaction: Transaction, transactions: Transaction[], accounts: Account[];

	let show = false,
		description = transaction.description,
		verification_number = transaction.verification_number,
		date = new Date(transaction.date),
		amount =
			transaction.debit_amount === '0' ? transaction.credit_amount : transaction.debit_amount,
		account_type: 'debit' | 'credit' = transaction.debit_amount === '0' ? 'credit' : 'debit',
		openDelete = false,
		account_id: number = transaction.account.id,
		poppup: poppup;

	const deleteTransaction = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`ledger/account/${transaction.account.id}/transactions/${transaction.id}/delete`
		);

		if (!res.ok) {
			poppup = { message: 'Something went wrong', success: false };
			return;
		}

		poppup = { message: 'Successfully deleted transaction', success: true };
		transactions = transactions.filter((transaction_) => transaction_.id !== transaction.id);
		openDelete = false;
	};

	const updateTransaction = async () => {
		const account = accounts.find((account) => account.id === account_id);

		if (!accounts || !account) return;

		const { res, json } = await fetchRequest(
			'POST',
			`ledger/account/${transaction.account.id}/transactions/${transaction.id}/update`,
			{
				debit_amount: account_type === 'debit' ? amount : 0,
				credit_amount: account_type === 'credit' ? amount : 0,
				description,
				verification_number,
				date,
				account_type,
				account
			}
		);

		if (!res.ok) {
			poppup = { message: 'Something went wrong', success: true };
			return;
		}

		poppup = { message: 'Successfully updated transaction', success: true };
		let newTransaction = deepCopy(transactions);

		newTransaction = newTransaction.filter((transaction_) => transaction_.id !== transaction.id);
		newTransaction.push({
			debit_amount: account_type === 'debit' ? amount : '0',
			credit_amount: account_type === 'credit' ? amount : '0',
			description,
			verification_number,
			date: date.toString(),
			account,
			id: transaction.id
		});
		transactions = newTransaction;
	};
</script>

<div>{transaction.account.account_name}</div>
<div>{transaction.account.account_number}</div>
<div>{transaction.debit_amount}</div>
<div>{transaction.credit_amount}</div>
<div>{transaction.description}</div>
<div>{transaction.verification_number}</div>
<div>{formatDate(transaction.date)}</div>
<div class="flex gap-2 ml-20">
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	<div on:click={() => (show = !show)} on:keydown class="cursor-pointer">
		<Fa icon={faScrewdriver} />
	</div>
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	<div on:click={() => (openDelete = !openDelete)} on:keydown class="cursor-pointer">
		<Fa icon={faTrash} />
	</div>
</div>

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
					<!-- value={accounts.find(account => account.id === account_id)} -->
					<Select
						labels={accounts.map((account) => `${account.account_name} ${account.account_number}`)}
						values={accounts.map((account) => account.id)}
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
		<Button action={updateTransaction}>Create Transaction</Button>
	</div>
</Modal>

<Modal bind:open={openDelete}>
	<div slot="header">Are you sure?</div>
	<div slot="body">
		<Button buttonStyle="warning" action={deleteTransaction}>Delete</Button>
		<Button action={() => (openDelete = false)}>Cancel</Button>
	</div>
</Modal>

<Poppup bind:poppup />

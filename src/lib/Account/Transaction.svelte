<script lang="ts">
	import type { Transaction } from './interface';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faScrewdriver, faTrash } from '@fortawesome/free-solid-svg-icons';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import type { Account } from '$lib/Account/interface';
	import Modal from '$lib/Generic/Modal.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { fetchRequest } from '$lib/FetchRequest';

	export let transaction: Transaction, accounts: Account[];

	let show = false,
		debit_amount = transaction.debit_amount,
		credit_amount = transaction.credit_amount,
		description = transaction.description,
		verification_number = transaction.verification_number,
		date = transaction.date;

	const deleteTransaction = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`ledger/account/${transaction.account.id}/transactions/${transaction.id}/delete`
		);
	};

	const updateTransaction = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`ledger/account/${transaction.account.id}/transactions/${transaction.id}/update`,
			{
				debit_amount,
				credit_amount,
				description,
				verification_number,
				date
			}
		);
	};
</script>

<div>{transaction.account.account_name}</div>
<div>{transaction.account.account_number}</div>
<div>{transaction.debit_amount}</div>
<div>{transaction.credit_amount}</div>
<div>{transaction.description}</div>
<div>{transaction.verification_number}</div>
<div>{transaction.date}</div>
<div class="flex gap-2 ml-20">
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	<div on:click={() => (show = !show)} on:keydown>
    <Fa icon={faScrewdriver} /></div>
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	<div on:click={deleteTransaction} on:keydown>
    <Fa icon={faTrash} /></div>
</div>

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
				<!-- <DateInput bind:value={date} /> -->
			</div>
			<Select
				labels={accounts.map((account) => account.account_name)}
				values={accounts.map((account) => account.id)}
				bind:value={transaction.account.id}
				onInput={(e) => {
					//@ts-ignore
					const selectedScore = e?.target?.value;
					transaction.account.id = Number(selectedScore);
				}}
			/>
		</form>
	</div>
	<div slot="footer">
		<Button action={updateTransaction}>Update Transaction</Button>
	</div>
</Modal>

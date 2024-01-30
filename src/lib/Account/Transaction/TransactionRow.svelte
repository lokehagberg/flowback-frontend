<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { DateInput } from 'date-picker-svelte';

	export let tx: any;
	const fields = `
		id,
		debit_amount,
		credit_amount,
		description,
		verification_number,
		date
	`
		.trim()
		.split(/,\s*/);

	let open = false,
		debit_amount: string = tx.debit_amount || 0,
		credit_amount: string = 0 || tx.credit_amount,
		description: string = tx.description,
		verification_number: string = tx.verification_number,
		date: Date = new Date(tx.date);

	const deleteTransaction = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`ledgeraccounts/${$page.params.accountId}/transactions/${tx.id}/delete`
		);
	};

	const updateTransaction = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`ledgeraccounts/${$page.params.accountId}/transactions/${tx.id}/update`,
			{
				debit_amount,
				credit_amount,
				description,
				verification_number,
				date
			}
		);
	};

	onMount(() => {
		console.log(tx);
	});
</script>

<tr on:click={() => (open = !open)}>
	{#each fields as field}
		<td>{(tx[field])}</td>
	{/each}
</tr>

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
		<Button action={deleteTransaction}>Delete Transaction</Button>
		<Button action={updateTransaction}>Update Transaction</Button>
	</div>
</Modal>

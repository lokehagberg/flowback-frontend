<script lang="ts">
	import TransactionRow from '$lib/Account/Transaction/TransactionRow.svelte';
	export let transactions = [];
	const fields = `
		id,
		debit_amount,
		credit_amount,
		description,
		verification_number,
		date
	`.trim().split(/,\s*/);
</script>
<table>
	{#each fields as field}
		<th>{field}</th>
	{/each}
	{#each transactions as tx}
		<TransactionRow {tx}/>
	{/each}
</table>

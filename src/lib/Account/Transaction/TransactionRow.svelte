<script lang="ts">
	export let tx;
	const fields = `
		id,
		debit_amount,
		credit_amount,
		description,
		verification_number,
		date
	`.trim().split(/,\s*/);
</script>
<tr>
	{#each fields as field}
		<td>{tx[field]}</td>
	{/each}
</tr>

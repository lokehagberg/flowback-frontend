<script lang="ts">
	import { _ } from 'svelte-i18n';
	import type { Account, Filter } from './interface';
	import Select from '$lib/Generic/Select.svelte';
	import DateInput from 'date-picker-svelte/DateInput.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { onMount } from 'svelte';
	import MultiSelect from '$lib/Generic/MultiSelect.svelte';
	import CheckboxButtons from '$lib/Generic/CheckboxButtons.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import Button from '$lib/Generic/Button.svelte';

	export let filter: Filter, handleSearch: () => {}, accounts: Account[];
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true,
		labels: { label: string; checked: boolean; id: number }[] = [],
		openFilterAccounts = false,
		filterOn = false;

	onMount(() => {
		labels = accounts?.map((account) => {
			return {
				label: `${account.account_name} ${account.account_number}`,
				checked: false,
				id: account.id
			};
		});
		console.log(labels, accounts);
	});

	const changingCheckbox = (id: number) => {
		let changeChecbox = filter.account_ids.find((label) => label.id === id);
		if (!changeChecbox) return;

		changeChecbox.checked = !changeChecbox.checked;

		filter.account_ids = filter.account_ids;
	};

	$: filter && handleSearch();
</script>

<form
	class="mt-6"
	on:submit|preventDefault={() => {
		searched = true;
	}}
>
	{#if filterOn}
		<Button onClick={() => (filterOn = false)}>Close Filter Options</Button>
		<div class="mt-5">
			<div class="mt-6">
				<label class="block" for="ledger-search">Search</label>
				<input
					id="ledger-search"
					type="text"
					class="bg-gray-200 dark:bg-darkbackground outline outline-1 outline-gray-300 w-full"
					bind:value={filter.description}
				/>
			</div>
			<div class="flex gap-2 mt-6">
				<div>Earliest Date<DateInput bind:value={filter.date_after} /></div>
				<div>Last Date<DateInput bind:value={filter.date_before} /></div>
			</div>
			<div class="mt-8">
				<Button action={() => (openFilterAccounts = true)}>Filter Accounts</Button>
			</div>
		</div>
	{:else}
		<Button onClick={() => (filterOn = true)}>Open Filter Options</Button>
	{/if}
</form>
<Modal bind:open={openFilterAccounts}>
	<div slot="header">Filter Accounts</div>
	<div slot="body">
		<CheckboxButtons
			onChange={changingCheckbox}
			label=""
			labels={filter.account_ids}
			Class={'flex flex-col text-left'}
		/>
		<!-- {#each accounts as account}
		
			{account.account_name} {account.account_number} -->
		<!-- {/each} -->
	</div>
</Modal>

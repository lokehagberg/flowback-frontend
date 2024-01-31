<script lang="ts">
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import AccountThumbnail from '$lib/Account/AccountThumbnail.svelte';
	import { accountsStore } from '$lib/Account/stores';
	import TransactionTable from '$lib/Account/Transaction/TransactionTable.svelte';
	import type { Transaction } from '$lib/Account/interface';

	let loading: boolean = true,
		transactions: Transaction[] = [],
		status: StatusMessageInfo,
		aggregatedBalance: number = 0;

	onMount(async () => {
		//@ts-ignore
		transactions = await accountsStore.get();

		console.log(transactions, 'TRANS');
		// totalBalance();

		loading = false;
	});

	const totalBalance = () => {
		transactions.forEach((account) => {
			// aggregatedBalance += account.balance;
		});
	};
</script>

<svelte:head>
	<title>{$_('Accounts')}</title>
</svelte:head>
<Layout centered>
	<!-- <Loader bind:loading>
		<StatusMessage bind:status disableSuccess />
		<div class="flex flex-col items-center mt-6 gap-6 mb-6 w-full">
			<Button href="accounts/add" Class="w-[40%] rounded-2xl">{$_('Add Account')}</Button>
			{#if accounts}
				<p class="dark:text-darkmodeText">
					{!accounts.length
						? 'There are no accounts currently'
						: accounts.length === 1
						? '1 account'
						: accounts.length + ' accounts'}
				</p>
				<p class="dark:text-darkmodeText">Aggregated Balance: {aggregatedBalance}</p>
				<ol class="md:grid lg:grid-cols-3 gap-6 2xl:grid-cols-5">
					{#each accounts as account}
						<li><AccountThumbnail {account} /></li>
					{/each}
				</ol>
			{/if}
		</div>
	</Loader> -->

	<div class="p-6 mt-6 dark:text-darkmodeText">
		<Loader bind:loading>
			<h1>Transactions</h1>
			<div class="grid grid-cols-7 gap-4 mt-3 bg-darkobject rounded shadow p-4">
				{#each transactions as transaction}
					<!-- <div>
						Account: {transaction.account_name}
						<code>{transaction.account_number}</code><br />
						Balance: {transaction.balance}
					</div> -->

					<!-- {@debug transaction} -->
					<!-- <div class="dark:bg-darkobject p-4 rounded shadow flex gap-10 mt-4"> -->
						<div>{transaction.account.account_name}</div>
						<div>{transaction.account.account_number}</div>
						<div>{transaction.debit_amount}</div>
						<div>{transaction.credit_amount}</div>
						<div>{transaction.description}</div>
						<div>{transaction.verification_number}</div>
						<div>{transaction.date}</div>
					<!-- </div> -->

				{/each}
			</div>
		</Loader>
	</div>
</Layout>

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

	let loading: boolean = true,
		accounts: any[] = [],
		status: StatusMessageInfo,
		aggregatedBalance:number = 0
	
		onMount(async () => {
		//@ts-ignore
		accounts = await accountsStore.get();
		
		totalBalance()
		
		loading = false;
	});

	const totalBalance = () => {
		accounts.forEach(account => {
			aggregatedBalance += account.balance
		});
	}
</script>

<svelte:head>
	<title>{$_('Accounts')}</title>
</svelte:head>
<Layout centered>
	<Loader bind:loading>
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
	</Loader>
</Layout>

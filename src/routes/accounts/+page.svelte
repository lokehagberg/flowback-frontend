<script lang="ts">
	import {onMount}        from 'svelte';
	import {_}              from 'svelte-i18n';
	import Button           from '$lib/Generic/Button.svelte';
	import Layout           from '$lib/Generic/Layout.svelte';
	import Loader           from '$lib/Generic/Loader.svelte';
	import StatusMessage    from '$lib/Generic/StatusMessage.svelte';
	import type {StatusMessageInfor} from '$lib/Generic/GenericFunctions';
	import AccountThumbnail from '$lib/Account/AccountThumbnail.svelte';
	import {accountsStore}  from '$lib/Account/stores';

	let
		loading: bool = true,
		accounts = {loaded: false},
		status: StatusMessageInfo;
	onMount(async ()=>{
		accounts = await accountsStore.get();
		loading = false;
		status = accounts.status;
	});
</script>
<svelte:head>
	<title>{$_("Accounts")}</title>
</svelte:head>
<Layout centering={true}>
	<Loader bind:loading>
		<StatusMessage bind:status disableSuccess/>
		<div class="flex flex-col items-center mt-6 gap-6 mb-6 w-full">
			<Button href="accounts/add" Class="w-[40%] rounded-2xl">{
				$_("Add Account")
			}</Button>
			{#if accounts.loaded}
				<p>{
					!accounts.length ?
						"0 accounts." :
					accounts.length === 1 ?
						"1 account:" :
						accounts.length + " accounts:"
				}</p>
				<ol>{#each accounts as account}
					<li><AccountThumbnail {account}/></li>
				{/each}</ol>
			{/if}
		</div>
	</Loader>
</Layout>

<script lang="ts">
	import Layout from '$lib/Generic/Layout.svelte';
	import {page} from '$app/stores';
	import AccountUpdater from '$lib/Account/AccountUpdater.svelte';
</script>
<svelte:head>
	<title>Flowback: Editing an Account</title>
</svelte:head>
<Layout centering>
	<AccountUpdater newOne={false} id={$page.params.accountId}/>
</Layout>

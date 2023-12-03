<script lang="ts">
	import AccountUpdater from '$lib/Account/AccountUpdater.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { _ } from 'svelte-i18n';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';

	let name: string = '',
		number: string = '',
		loading: boolean = false,
		status: StatusMessageInfo;

	const addAccount = async () => {
		loading = true;
		const formData = new FormData();

		formData.append('account_name', name);
		formData.append('account_number', number);

		const { res, json } = await fetchRequest(
			'POST',
			'ledger/accounts/create',
			formData,
			true,
			false
		);

		if (!res.ok) {
			status = statusMessageFormatter(res, json);
			loading = false;
			return;
		}

		window.location.href = '/accounts';
		loading = false;
	};
</script>

<svelte:head>
	<title>Flowback: {$_('Adding an Account')}</title>
</svelte:head>
<Layout centered>
	<Loader bind:loading>
		<AccountUpdater id={1} newOne={true} />
	</Loader>
</Layout>

<script>
	import { fetchRequest } from '$lib/FetchRequest';
	import Layout from '$lib/Generic/Layout.svelte';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	onMount(async () => {
		{
			const { json, res } = await fetchRequest('POST', 'membership/generate_payment');
		}

		{
			const { json, res } = await fetchRequest('POST', 'membership/validate_payment');
		}
	});
</script>

<!-- <Layout centering={true}>
	<div class="bg-white p-6 shadow rounded mt-6">{$_("Under Construction")}</div>
</Layout> -->

<Layout />

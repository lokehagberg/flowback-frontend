<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import Layout from '$lib/Generic/Layout.svelte';

	const generatePayment = async () => {
		{
			const { json, res } = await fetchRequest('POST', 'membership/generate_payment');
			console.log(json, 'LINK');
			window.open(json, 'newwindow', 'height=900px,width=1000px');
		}
	};
</script>

<Layout>
	<ButtonPrimary action={generatePayment}>PAY UP</ButtonPrimary>
</Layout>

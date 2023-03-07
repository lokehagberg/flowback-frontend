<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
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
	<Button action={generatePayment}>PAY UP</Button>
</Layout>

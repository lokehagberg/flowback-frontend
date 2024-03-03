<script>
	import { fetchRequest } from '$lib/FetchRequest';
	import Layout from '$lib/Generic/Layout.svelte';
	import { onMount } from 'svelte';

	const getAI = async () => {
		const { res, json } = await fetchRequest('GET', 'ai/test');
		console.log(json);
	};

	onMount(() => {
		getAI();
	});
</script>

<Layout>
	<div>welcome to AI</div>
</Layout>

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { onMount } from 'svelte';

	let prompt = '',
		response: string[] = [];

	const getAI = async () => {
		const { res, json } = await fetchRequest('POST', 'ai/test', { prompt });
		response = json;
	};
</script>

<Layout>
	<div>welcome to AI</div>

	<TextInput label="AI prompt" bind:value={prompt} />
	<Button action={getAI} />
	<div>
		{#each response as item}
			<div class="p-4 dark:bg-darkobject dark:text-white">
				{item}
			</div>
		{/each}
	</div>
</Layout>

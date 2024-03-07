<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { onMount } from 'svelte';

	let prompt = '',
		poll_titles: string[] = [],
		areas:string[] = [],
		title_selected: string,
		area_selected:string;

	const getAI = async () => {
		const { res, json } = await fetchRequest('POST', 'ai/titles', { prompt });
		poll_titles = json.titles;
		areas = json.areas
	};
	
	const generatePoll = async () => {
		const { res, json } = await fetchRequest('POST', 'ai/titles', { prompt });
	}
</script>

<Layout>
	<div>welcome to AI</div>

	<TextInput label="AI prompt" bind:value={prompt} />
	<Button action={getAI} />
	<div>
		<RadioButtons2
			Class="p-4 dark:bg-darkobject dark:text-white"
			ClassInput="mt-1 mb-1"
			bind:labels={poll_titles}
			bind:values={poll_titles}
			bind:value={title_selected}
			name="polls"
		/>
		<RadioButtons2
			Class="p-4 dark:bg-darkobject dark:text-white"
			ClassInput="mt-1 mb-1"
			bind:labels={areas}
			bind:values={areas}
			bind:value={area_selected}
			name="areas"
		/>
	</div>

	<Button action={generatePoll}>Generate Poll</Button>
</Layout>

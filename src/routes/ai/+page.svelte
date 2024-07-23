<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Loader from '$lib/Generic/Loader.svelte';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';
	import Select from '$lib/Generic/Select.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Results from '$lib/Poll/Results.svelte';
	import Statistics from '$lib/Poll/Statistics.svelte';
	import { onMount } from 'svelte';

	let prompt = '',
		poll_titles: string[] = [],
		areas: string[] = [],
		title_selected: string,
		area_selected: string,
		poll: { proposals: string[]; predictions: string[]; bets: string[]; voting: string[] },
		loading = false;

	const getAI = async () => {
		loading = true;
		const { res, json } = await fetchRequest('POST', 'ai/titles', { prompt });
		poll_titles = json.titles;
		areas = json.areas;
		loading = false;
	};

	const generatePoll = async () => {
		loading = true;
		const { res, json } = await fetchRequest('POST', 'ai/poll', {
			area: area_selected,
			title: title_selected
		});

		poll = json;
		loading = false;
	};
</script>

<Layout>
	<Loader bind:loading>
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

		<div class="p-4 dark:bg-darkobject dark:text-white">
			{#if poll}
				<div>
					{#each poll.proposals as proposal}
						<div>{proposal}</div>
					{/each}
				</div>
				<div>
					{#each poll.predictions as prediction}
						<div>{prediction}</div>
					{/each}
				</div>
				<div>
					{#each poll.bets as bet}
						<div>{bet}</div>
					{/each}
				</div>
				<div>
					{#each poll.voting as vote}
						<div>{vote}</div>
					{/each}
				</div>

				<Statistics labels={poll.proposals} votes={[60, 56, 60, 20, 50]} />
			{/if}
		</div>
		<Button action={generatePoll}>Generate Poll</Button>
	</Loader>
</Layout>

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from './Button.svelte';

	export let prev: string,
		next: string,
		iterable: any[],
		Class = '';

	const request = async (api: string) => {
		const { res, json } = await fetchRequest('GET', api);

		next = json.next;
		prev = json.previous;
		iterable = json.results;
	};
</script>

<div class={`${Class} text-white dark:text-darkmodeText`}>
	{#if prev}
		<Button Class="py-1 px-2" onClick={() => request(prev)}>Previous</Button>
		<!-- <button class="p-2 bg-primary cursor-pointer rounded-md" on:click={() => request(prev)}>Previous</button> -->
	{/if}
	{#if next}
		<Button Class="py-1 px-2" onClick={() => request(next)}>Next</Button>
		<!-- <button class="p-2 bg-primary cursor-pointer rounded-md" on:click={() => request(next)}>Next</button> -->
	{/if}

	<!-- {#each [1,2,3,4,5] as number}
        <div class="p-2 bg-primary">{number}</div>
    {/each} -->
</div>

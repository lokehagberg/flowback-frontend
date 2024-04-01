<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { poll } from '$lib/Poll/interface';

	export let prev: string, next: string, iterable: poll[], Class = ""

	const request = async (api: string) => {
		const { res, json } = await fetchRequest('GET', api);

		console.log(res, json);
		next = json.next;
		prev = json.previous;
		iterable = json.results;
	};
</script>


<div class={`${Class}`}>
	{#if prev}
		<button class="p-2 bg-primary cursor-pointer" on:click={() => request(prev)}>Previous</button>
	{/if}
	{#if next}
		<button class="p-2 bg-primary cursor-pointer" on:click={() => request(next)}>Next</button>
	{/if}

	<!-- {#each [1,2,3,4,5] as number}
        <div class="p-2 bg-primary">{number}</div>
    {/each} -->
</div>

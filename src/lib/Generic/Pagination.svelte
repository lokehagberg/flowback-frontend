<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { poll } from '$lib/Poll/interface';

	export const Class = '';
	export let prev: string, next: string, polls: poll[];

	const request = async (api: string) => {
		const { res, json } = await fetchRequest('GET', api);

		console.log(res, json);
		next = json.next;
		prev = json.previous;
		polls = json.results;
	};
</script>

<div class={`${Class} flex gap-2 justify-around w-full `}>
	{#if prev}
		<!-- svelte-ignore a11y-click-events-have-key-events -->
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<div class="p-2 bg-primary cursor-pointer" on:click={() => request(prev)}>Previous</div>
	{/if}
	{#if next}
		<!-- svelte-ignore a11y-click-events-have-key-events -->
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<div class="p-2 bg-primary cursor-pointer" on:click={() => request(next)}>Next</div>
	{/if}

	<!-- {#each [1,2,3,4,5] as number}
        <div class="p-2 bg-primary">{number}</div>
    {/each} -->
</div>

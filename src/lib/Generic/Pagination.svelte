<script lang="ts">
	import { env } from '$env/dynamic/public';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from './Button.svelte';
	import { _ } from 'svelte-i18n';
	import { commaCleanup } from './GenericFunctions';

	export let prev: string,
		next: string,
		iterable: any[],
		Class = '';

	const request = async (api: string) => {
		api = commaCleanup(api);
		api = api.replace(`${env.PUBLIC_API_URL}/`, '');
		api = api.replace(`api/api`, 'api');

		const { res, json } = await fetchRequest('GET', api);

		if (!res.ok) return;

		next = commaCleanup(json.next);
		prev = commaCleanup(json.previous);
		iterable = json.results;
	};
</script>

<div class={`${Class} text-white dark:text-darkmodeText`}>
	{#if prev}
		<Button Class="py-1 px-2" onClick={() => request(prev)}>{$_('Previous')}</Button>
		<!-- <button class="p-2 bg-primary cursor-pointer rounded-md" on:click={() => request(prev)}>Previous</button> -->
	{/if}
	{#if next}
		<Button Class="py-1 px-2" onClick={() => request(next)}>{$_('Next')}</Button>
		<!-- <button class="p-2 bg-primary cursor-pointer rounded-md" on:click={() => request(next)}>Next</button> -->
	{/if}

	<!-- {#each [1,2,3,4,5] as number}
        <div class="p-2 bg-primary">{number}</div>
    {/each} -->
</div>

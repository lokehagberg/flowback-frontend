<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { Tag } from './interface';

	export let tag: Tag,
		Class: string = '',
		onclick = () => {};

	const getMeanAbsoluteError = async () => {
		console.log(tag, "LE TAG")
		const { res, json } = await fetchRequest('GET', `group/tag/${tag.id}/imae`);
		if (!res.ok) return

		tag.mae  = json?.results
	};

	onMount(() => {
		getMeanAbsoluteError();
	});
</script>

<!-- {@debug tag} -->
<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	class={'select-none text-xs tag text-center bg-gray-400 text-white pl-4 pr-4 pt-1 pb-1 break-words rounded ' +
		Class}
	on:click={onclick}
>
	{tag?.name}

	{#if tag?.mae}
		{tag?.mae}
	{/if}
</div>

<style>
	.tag {
		transition: background-color 400ms cubic-bezier(0.075, 0.82, 0.165, 1);
	}
</style>

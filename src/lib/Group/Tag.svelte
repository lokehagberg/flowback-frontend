<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { Tag } from './interface';
	import { elipsis } from '$lib/Generic/GenericFunctions';

	export let tag: Tag,
		Class: string = '',
		onclick = () => {},
		imac: boolean = true;

	//Interval Mean Absolute Correctness
	const getMeanAbsoluteError = async () => {
		if (!imac) return;

		const { res, json } = await fetchRequest('GET', `group/tag/${tag.id}/imac`);
		if (!res.ok) return;

		tag.imac = json;
	};

	onMount(() => {
		getMeanAbsoluteError();
	});
</script>

<div class="flex">
	<button
		class={'items-center select-none text-xs tag text-center bg-accent-tertiary text-black px-4 py-1 break-words ' +
			(imac ? 'rounded-l' : 'rounded') + ' ' + Class}
		on:click={onclick}
	>
		{elipsis(tag?.name, 20)}
	</button>

	{#if imac}
		<div class="border-accent-tertiary px-1 border-2 w-[20%] text-center text-black text-xs dark:text-darkmodeText rounded-r">
			{#if tag?.imac}
				({tag?.imac})
			{:else}
				?
			{/if}
		</div>
	{/if}
</div>

<style>
	.tag {
		transition: background-color 400ms cubic-bezier(0.075, 0.82, 0.165, 1);
	}
</style>

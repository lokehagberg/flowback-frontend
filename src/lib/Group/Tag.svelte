<script lang="ts">
	import type { Tag } from './interface';
	import { elipsis } from '$lib/Generic/GenericFunctions';
	import { imacFormatting } from '$lib/Poll/functions';

	export let tag: Tag,
		Class: string = '',
		onclick = () => {},
		displayImac: boolean = true,
		id = 'tag';
</script>

<div class="flex">
	<button
		class={'items-center select-none text-xs tag text-center bg-accent-tertiary dark:bg-slate-500 dark:text-darkmodeText text-black px-4 py-1 break-words ' +
			(displayImac ? 'rounded-l' : 'rounded') +
			' ' +
			Class}
		on:click={onclick}
		{id}
	>
		{elipsis(tag?.name, 20)}
	</button>

	{#if displayImac}
		<div
			class="border-accent-tertiary px-1 border-2 w-auto min-w-[20%] content-center text-center text-black text-xs dark:bg-slate-500 dark:text-darkmodeText rounded-r"
			id={id + '-imac'}
		>
			{#if tag?.imac}
				{imacFormatting(tag.imac)}
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

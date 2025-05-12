<script lang="ts">
	import { _ } from 'svelte-i18n';

	export let limit: number = 2,
		lengthLimit: number = 200,
		description: string,
		Class = '',
		readMore = false;
</script>

<div class={`dark:text-darkmodeText ${Class}`}>
	<p
		class="text-black dark:text-darkmodeText break-words overflow-hidden whitespace-pre-wrap"
		class:line-clamp={!readMore}
		style={!readMore ? `-webkit-line-clamp: ${limit}; -webkit-box-orient: vertical; display: -webkit-box;` : ''}
	>
		{description}
	</p>

	{#if description.length > lengthLimit}
		<button
			class="text-gray-600 font-bold hover:underline cursor-pointer" on:click={() => (readMore = !readMore)}>
			{$_(readMore ? 'Show less' : 'Show more')}...
		</button>
	{/if}
</div>
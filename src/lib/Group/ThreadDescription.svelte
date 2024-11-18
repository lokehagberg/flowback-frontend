<script lang="ts">
	import { _ } from 'svelte-i18n';

	export let limit: number,
		description: string = '',
		Class = '';

	let readMore = false;
</script>

<p class={`whitespace-pre-wrap break-words mt-2 dark:text-darkmodeText ${Class}`}>
	{#if readMore}
		<div class=" text-black">
			{description}
		</div>

		{#if description.length > limit}
			<button
				class="hover:underline cursor-pointer text-gray-600 font-bold ml-3"
				on:click={() => (readMore = false)}>{$_('Show less')}...</button
			>
		{/if}
	{:else}
		<div class="cursor-pointe text-black">
			{description.slice(0, limit)}
		</div>

		{#if description.length > limit}
			...<button
				class="hover:underline cursor-pointer text-gray-600 font-bold ml-3"
				on:click={() => (readMore = true)}>{$_('Show more')}...</button
			>
		{/if}
	{/if}
</p>

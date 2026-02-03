<script lang="ts">
	import { faChevronDown, faChevronUp } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
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
		style={!readMore
			? `-webkit-line-clamp: ${limit}; -webkit-box-orient: vertical; display: -webkit-box;`
			: ''}
	>
		{description}
	</p>

	{#if description.length > lengthLimit}
		<button
			class="w-full justify-center flex text-gray-600 font-bold hover:underline cursor-pointer"
			on:click={() => (readMore = !readMore)}
		>
			<!-- {$_(readMore ? 'Show less' : 'Show more')}... -->
			{#if readMore}
				<Fa icon={faChevronUp} />
			{:else}
				<Fa icon={faChevronDown} />
			{/if}
		</button>
	{/if}
</div>

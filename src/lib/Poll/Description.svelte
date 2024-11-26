<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { elipsis } from '$lib/Generic/GenericFunctions';

	export let limit: number,
		description: string,
		Class = '';

	let readMore = false;
</script>

<div class={` break-all dark:text-darkmodeText ${Class}`}>
	<p class=" text-black">
		<!-- TODO: Ensure that the 5000 description limit is accessible more easily and universally across files -->
		{elipsis(description, readMore ? 5000 : limit)}
	</p>

	{#if description.length > limit}
		<button
			class="hover:underline cursor-pointer text-gray-600 font-bold"
			on:click={() => (readMore = !readMore)}>{$_(readMore ? 'Show less' : 'Show more')}...</button
		>
	{/if}
</div>

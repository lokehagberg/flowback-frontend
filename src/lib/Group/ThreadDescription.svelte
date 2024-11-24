<script lang="ts">
	import { elipsis } from '$lib/Generic/GenericFunctions';
	import { _ } from 'svelte-i18n';

	export let limit: number = 400,
		description: string = '',
		Class = '';

	let readMore = false;
</script>

<div class={`whitespace-pre-wrap break-words mt-2 dark:text-darkmodeText ${Class}`}>
	<p class=" text-black">
		<!-- TODO: Ensure that the 5000 description limit is accessible more easily and universally across files -->
		{elipsis(description, readMore ? 5000 : limit)}
	</p>

	<button
		class="hover:underline cursor-pointer text-gray-600 font-bold"
		on:click={() => (readMore = !readMore)}>{$_(readMore ? 'Show less' : 'Show more')}...</button
	>
</div>

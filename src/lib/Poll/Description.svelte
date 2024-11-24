<script lang="ts">
	import type { poll } from './interface';
	import { page } from '$app/stores';
	import { _ } from 'svelte-i18n';
	import { elipsis } from '$lib/Generic/GenericFunctions';

	export let limit: number,
		poll: any,
		onHoverGroup: boolean = false,
		Class = '';

	let readMore = false;
</script>

<div class={`whitespace-pre-wrap break-all dark:text-darkmodeText ${Class}`}>
	<p class=" text-black">
		<!-- TODO: Ensure that the 5000 description limit is accessible more easily and universally across files -->
		{elipsis(poll.description, readMore ? 5000 : limit)}
	</p>

	<button
		class="hover:underline cursor-pointer text-gray-600 font-bold"
		on:click={() => (readMore = !readMore)}>{$_(readMore ? 'Show less' : 'Show more')}...</button
	>
</div>


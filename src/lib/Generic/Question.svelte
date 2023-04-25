<script lang="ts">
	import { faQuestion } from '@fortawesome/free-solid-svg-icons/faQuestion';
	import Fa from 'svelte-fa/src/fa.svelte';

	let show = false;
</script>

<div class="relative w-full">
	<div on:mouseover={() => (show = true)} on:mouseleave={() => (show = false)}  on:focus >
		<Fa
			class="rounded-full border border-opacity-40 border-gray-400 px-[3px] hover:bg-gray-200 bg-white cursor-pointer"
			icon={faQuestion}
		/>
	</div>
	{#if show}
		<div class="absolute top-4 bg-white text-sm p-3">
			Hi longer test iHi longer test iHi longer test iHi longer test iHi longer test iHi longer test
			i
		</div>
	{/if}
</div>

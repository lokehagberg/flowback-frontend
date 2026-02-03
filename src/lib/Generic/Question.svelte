<script lang="ts">
	import { faQuestion } from '@fortawesome/free-solid-svg-icons/faQuestion';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';

	export let message = '';

	let show = false;
</script>

<button
	class="inline"
	on:mouseover={() => (show = true)}
	on:mouseleave={() => (show = false)}
	on:focus={() => (show = true)}
	on:blur={() => (show = false)}
	aria-describedby="Tooltip"
	tabindex="0"
>
	<Fa
		size={'0.8x'}
		class="inline rounded-full border border-opacity-40 border-gray-400 px-[3px] hover:bg-gray-200 dark:hover:bg-gray-800 dark:bg-darkobject bg-white cursor-pointer"
		icon={faQuestion}
	/>
</button>

<div class="inline relative w-full">
	{#if show}
	<div 
			id="tooltip"
			role="tooltip" 
			class="absolute top-4 bg-white text-sm p-3 z-50 rounded border dark:bg-darkobject dark:text-darkmodeText"
		>
			{$_(message)}
		</div>
	{/if}
</div>
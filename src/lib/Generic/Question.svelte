<script lang="ts">
	import { faQuestion } from '@fortawesome/free-solid-svg-icons/faQuestion';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';

	export let message = '';

	let show = false;
</script>

<!-- svelte-ignore a11y-interactive-supports-focus -->
<div
	class="inline"
	on:mouseover={() => (show = true)}
	on:mouseleave={() => (show = false)}
	on:focus={() => (show = true)}
	on:blur={() => (show = false)}
	aria-describedby="Tooltip"
	role="button"
>
	<Fa
		size={'0.8x'}
		class="inline rounded-full border border-opacity-40 border-gray-400 px-[3px] hover:bg-gray-200 dark:hover:bg-gray-800 dark:bg-darkobject bg-white cursor-pointer"
		icon={faQuestion}
	/>
</div>
{#if show}
	<div
		class="absolute w-full top-5 break-words bg-white dark:bg-darkobject text-sm p-4 shadow-md rounded"
	>
		{$_(message)}
	</div>
{/if}

<!-- <div class="inline relative w-full">
	<div class="inline rounded-full border border-opacity-40 border-gray-400 px-[3px] hover:bg-gray-200 bg-white cursor-pointer" on:mouseover={() => (show = true)} on:mouseleave={() => (show = false)} on:focus>
	</div>
	{#if show}
		<div class="absolute top-4 bg-white text-sm p-3">
			{$_(message)}
		</div>
	{/if}
</div> -->

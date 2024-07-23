<script lang="ts">
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';

	export let text: string,
		action = () => {},
		icon = faPoll,
		isSelected = true;

	let hovering = false;
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	on:mouseover={() => (hovering = true)}
	on:mouseleave={() => (hovering = false)}
	on:focus
	on:keydown
	on:click={action}
	class={`select-none flex item-center items-center outline-gray-400 dark:outline-gray-700 ${
		!isSelected && 'hover:outline dark:hover:brightness-125 hover:brightness-150'
	} outline-1 cursor-pointer p-4 ${isSelected && 'text-gray-400 dark:text-gray-500'}`}
>
	<Fa {icon} />
	<div class="ml-2">
		{$_(text)}
	</div>
</div>

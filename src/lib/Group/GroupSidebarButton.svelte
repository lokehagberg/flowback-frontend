<script lang="ts">
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';

	export let text: string;
	export let action = () => {};
	export let icon = faPoll
	export let isSelected = true;

	let hovering = false;
</script>

<div
	on:mouseover={() => (hovering = true)}
	on:mouseleave={() => (hovering = false)}
	on:focus
	on:keydown
	on:click={action}
	class={`select-none flex item-center items-center hover:outline outline-gray-200 dark:outline-gray-700 hover:brightness-125 outline-1 cursor-pointer p-4 ${isSelected && "text-gray-300 dark:text-gray-500"}`}
>
	<Fa {icon}  />
	<div class="ml-2">
		{$_(text)}
	</div>
</div>

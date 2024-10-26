<script lang="ts">
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';

	export let text: string,
		action = () => {},
		icon = faPoll,
		isSelected = true;

	let hovering = false;
</script>

<button
	on:mouseover={() => (hovering = true)}
	on:mouseleave={() => (hovering = false)}
	on:focus
	on:click={action}
	class={`select-none flex item-center items-center outline-gray-400 dark:outline-gray-700 ${
		!isSelected && 'hover:outline dark:hover:brightness-125 hover:brightness-150'
	} outline-1 cursor-pointer p-4 ${isSelected && 'text-gray-400 dark:text-gray-500'}`}
>
	<Fa {icon} />
	<div class="ml-2">
		{$_(text)}
	</div>
</button>

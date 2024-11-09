<script lang="ts">
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';

	export let text: string,
		action = () => {},
		icon = faPoll,
		isSelected = true,
		Class = '';

	let hovering = false;
</script>

<button
	on:mouseover={() => (hovering = true)}
	on:mouseleave={() => (hovering = false)}
	on:focus
	on:click={action}
	class={`${Class} select-none flex item-center items-center  dark:outline-gray-700 rounded-md transition-all  ${
		!isSelected && 'hover:bg-gray-200 active:bg-gray-300  '
	} outline-1 cursor-pointer p-3 ${
		isSelected && 'text-gray-400 dark:text-gray-500 border-l-2 border-primary'
	} `}
>
	<Fa {icon} />
	<div class="ml-2">
		{$_(text)}
	</div>
</button>

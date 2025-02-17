<script lang="ts">
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';

	export let text: string,
		action = () => {},
		icon = faPoll,
		isSelected = true,
		Class = '',
		disabled = false;

	let hovering = false;
</script>

<button
	on:mouseover={() => (hovering = true)}
	on:mouseleave={() => (hovering = false)}
	on:focus
	on:click={action}
	class={`${Class} select-none flex items-center rounded transition-all outline-1 cursor-pointer p-3 cursor-pointer dark:outline-gray-700
		${isSelected 
			? 'bg-gray-200 text-black border-l-2 rounded-none border-primary dark:bg-gray-700 dark:text-white' 
			: 'hover:bg-gray-200 active:bg-gray-300 dark:hover:bg-gray-700 active:dark:bg-gray-600'
		}
		${disabled ? 'opacity-50 saturate-0 cursor-not-allowed' : ''}
	`}
	aria-disabled={disabled}
>
	<Fa {icon} class="max-w-[24px]"/>
	<div class="ml-4">
		{$_(text)}
	</div>
</button>

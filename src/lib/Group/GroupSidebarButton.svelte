<script lang="ts">
	import { faBarsProgress, type IconDefinition } from '@fortawesome/free-solid-svg-icons';
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';

	export let text: string,
		action = () => {},
		faIcon: IconDefinition = faBarsProgress,
		svgIcon: string = '',
		isSelected = true,
		Class = '',
		disabled = false;

	let hovering = false;
</script>

{#if svgIcon === ''}
	<button
		on:mouseover={() => (hovering = true)}
		on:mouseleave={() => (hovering = false)}
		on:focus
		on:click={action}
		class={`${Class} text-left select-none flex items-center rounded transition-all outline-1 cursor-pointer p-3 pr-5 dark:outline-gray-700
		${
			isSelected
				? 'bg-gray-200 text-black border-l-2 rounded-none border-primary dark:bg-gray-700 dark:text-white'
				: 'hover:bg-gray-200 active:bg-gray-300 dark:hover:bg-gray-700 active:dark:bg-gray-600'
		}
		${disabled ? 'opacity-50 saturate-0 cursor-not-allowed' : ''}
	`}
		aria-disabled={disabled}
	>
		<div class="w-6 flex items-center justify-center">
			<Fa icon={faIcon} class="w-6 h-6" />
		</div>
		<div class="ml-3 text-left">
			{$_(text)}
		</div>
	</button>
{:else}
	<button
		on:mouseover={() => (hovering = true)}
		on:mouseleave={() => (hovering = false)}
		on:focus
		on:click={action}
		class={`${Class} text-left select-none flex items-center rounded transition-all outline-1 cursor-pointer p-3 pr-5 dark:outline-gray-700
		${
			isSelected
				? 'bg-gray-200 text-black border-l-2 rounded-none border-primary dark:bg-gray-700 dark:text-white'
				: 'hover:bg-gray-200 active:bg-gray-300 dark:hover:bg-gray-700 active:dark:bg-gray-600'
		}
		${disabled ? 'opacity-50 saturate-0 cursor-not-allowed' : ''}
	`}
		aria-disabled={disabled}
		><img class="w-6" src={svgIcon} alt={`${$_(text)}`} />
		<div class="ml-4 text-left">
			{$_(text)}
		</div>
	</button>
{/if}

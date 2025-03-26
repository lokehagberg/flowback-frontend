<script lang="ts">
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	export let onClick = () => {},
		Class = '',
		buttonStyle: buttonstyles = 'primary',
		type: buttontypes = 'button',
		disabled = false,
		label: string = '',
		href = '',
		hoverEffect = true;

	//If all you send in is ref without noClick, the button will automatically send one to that link if pressed.
	onMount(() => {
		if (href !== '')
			onClick = () => {
				goto(href);
			};
	});

	type buttonstyles =
		| 'primary'
		| 'secondary'
		| 'warning'
		| 'warning-light'
		| 'accent-secondary'
		| 'accent'
		| 'primary-light'
		| 'inactive';

	type buttontypes = 'button' | 'submit';
</script>

<!-- role={type === 'button' ? 'button' : type === 'submit' ? 'submit' : ''} -->
<button
	{type}
	on:click={() => {
		//The button used to only have action, but onClick is standard for svelte. TODO: Refactor so we only have onClick on all buttons in the code.
		onClick();
	}}
	class={`text-center ${
		Class.includes('bg-') ? '' : 'bg-primary'
	} ${Class} filter inline text-white rounded-md cursor-pointer p-2 transition-all duration-50 
	${buttonStyle === 'primary-light' && ' bg-white dark:bg-darkobject primary-light-inner-shadow'}
	${
		buttonStyle === 'warning-light' &&
		' bg-white dark:bg-darkobject dark:text-darkmodeText !text-red-400 border-[1px] border-red-400'
	}`}
	class:hover:brightness-[90%]={hoverEffect}
	class:active:brightness-[92%]={hoverEffect}
	class:!border-gray-300={disabled}
	class:!cursor-default={disabled}
	class:!hover:bg-white={disabled}
	class:!text-gray-300={disabled}
	class:!bg-secondary={buttonStyle == 'secondary'}
	class:!bg-red-500={buttonStyle === 'warning'}
	class:!bg-accent={buttonStyle === 'accent'}
	class:!bg-accentSecondary={buttonStyle === 'accent-secondary'}
	{disabled}
	value={$_(label)}
>
	{#if label !== ''}
		{$_(label)}
	{/if}
	<slot />
</button>

<style>
	.primary-light-inner-shadow {
		/* box-shadow: inset 0 0 0px 3px rgb(130, 180, 230); */
		border: 1px solid var(--secondary);
		color: var(--secondary);
		font-weight: 500;
		font-size: medium;
	}
</style>

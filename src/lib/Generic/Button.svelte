<script lang="ts">
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	export let onClick = (e: any) => {},
		Class = '',
		buttonStyle: buttonstyles = 'primary',
		type: buttontypes = 'button',
		disabled = false,
		label: string = '',
		href = '',
		hoverEffect = true,
		id = '';

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
		| 'default'
		| 'inactive';

	type buttontypes = 'button' | 'submit';
</script>

<!-- role={type === 'button' ? 'button' : type === 'submit' ? 'submit' : ''} -->
<button
	{id}
	{type}
	on:click={(e) => {
		onClick(e);
	}}
	class={`text-center dark:saturate-[60%] transition-colors duration-50 ${
		Class.includes('bg-') ? '' : 'bg-primary'
	} ${Class}  inline text-white rounded-md cursor-pointer p-2  
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
	class:!bg-gray-700={buttonStyle === 'default'}
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

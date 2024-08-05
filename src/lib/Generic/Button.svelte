<script lang="ts">
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	export let action = () => {},
		onClick = () => {},
		Class = '',
		buttonStyle: buttonstyles = 'primary',
		type: buttontypes = 'default',
		disabled = false,
		label: string = '',
		href = '';

	onMount(() => {
		if (href !== '')
			action = () => {
				goto(href);
			};
	});

	type buttonstyles =
		| 'primary'
		| 'secondary'
		| 'warning'
		| 'accent-secondary'
		| 'accent'
		| 'primary-light';
	type buttontypes = 'default' | 'submit';
</script>

<!-- 
	The reason for the split between default and submit is that submit buttons
	work differently in forms
 -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
{#if type === 'default'}
	<!-- svelte-ignore a11y-click-events-have-key-events -->
	<div
		on:click|preventDefault={() => {
			//The button used to only have action, but onClick is standard for svelte. TODO: Refactor so we only have onClick on all buttons in the code.
			action();
			onClick();
		}}
		class={`text-center ${
			Class.includes('bg-') ? '' : 'bg-primary'
		} filter hover:brightness-50 inline text-white rounded-md cursor-pointer  ${Class} hover:brightness-[95%] active:brightness-[92%] transition-all duration-50 

		${buttonStyle === 'primary-light' ? ' !bg-white  primary-light-inner-shadow text-xl' : ''}`}
		class:bg-gray-300={disabled}
		class:!bg-secondary={buttonStyle == 'secondary'}
		class:!bg-red-500={buttonStyle === 'warning'}
		class:!bg-accent={buttonStyle === 'accent'}
		class:!bg-accentSecondary={buttonStyle === 'accent-secondary'}
		>
		<slot />
	</div>
{:else if type === 'submit'}
	<button
		type="submit"
		class={`text-center ${
			Class.includes('bg-') ? '' : 'bg-primary'
		} filter hover:brightness-50 inline text-white rounded-md cursor-pointer  ${Class} hover:brightness-[95%] active:brightness-[92%] transition-all duration-50 

		${buttonStyle === 'primary-light' ? ' !bg-white  primary-light-inner-shadow text-xl' : ''}`}
		class:bg-gray-300={disabled}
		class:!bg-secondary={buttonStyle == 'secondary'}
		class:!bg-red-500={buttonStyle === 'warning'}
		class:!bg-accent={buttonStyle === 'accent'}
		class:!bg-accentSecondary={buttonStyle === 'accent-secondary'}
		{disabled}
		value={$_(label)}
		><slot />{$_(label)}
	</button>
{/if}

<style>
	.primary-light-inner-shadow {
		/* box-shadow: inset 0 0 0px 3px rgb(130, 180, 230); */
		border: 1px solid var(--secondary);
		color:var(--secondary) !important;
		font-weight:500;
		font-size:medium
	}
</style>

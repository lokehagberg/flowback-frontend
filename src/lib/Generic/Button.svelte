<script lang="ts">
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	export let action = () => {},
		Class = '',
		buttonStyle: buttonstyles = 'primary',
		type: buttontypes = 'default',
		disabled = false,
		label:string = "",
		href = ""

	onMount(() => {
		if (href !== "") action = () => { window.location.href = href }
	})

	type buttonstyles = 'primary' | 'secondary';
	type buttontypes = 'default' | 'submit';
</script>

<!-- 
	The reason for the split between default and submit is that submit buttons
	work differently in forms
 -->
{#if type === 'default'}
	<div
		on:click|preventDefault={action}
		class={`text-center ${Class.includes("bg-") ? "" : "bg-primary"} filter hover:brightness-50 inline text-white pl-6 pr-6 pt-2 pb-2 rounded cursor-pointer ${Class} hover:brightness-[85%] active:brightness-[92%] transition-all duration-50`}
		class:bg-gray-300={disabled}
		class:bg-blue-200={buttonStyle == 'secondary'}
	>
		<slot />
	</div>
{:else if type === 'submit'}
	<button
		type="submit"
		class={`text-center inline bg-primary text-white pl-6 pr-6 pt-2 pb-2 rounded cursor-pointer ${Class} hover:brightness-[85%] active:brightness-[92%] transition-colors`}
		class:bg-blue-200={buttonStyle == 'secondary'}
		disabled={disabled}
		value={$_(label)}
	><slot/>{$_(label)} </button>
{/if}

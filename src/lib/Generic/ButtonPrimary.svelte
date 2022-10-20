<script lang="ts">
	export let action = () => {},
		Class = '',
		buttonStyle: buttonstyles = 'primary',
		type: buttontypes = 'default',
		disabled = false;

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
		class={`text-center ${Class.includes("bg-") ? "" : "bg-blue-600"} inline text-white pl-6 pr-6 pt-2 pb-2 rounded cursor-pointer ${Class}`}
		class:bg-gray-300={disabled}
		class:bg-blue-200={buttonStyle == 'secondary'}
		disabled={disabled}
	>
		<slot />
	</div>
{:else if type === 'submit'}
	<input
		type="submit"
		class={`text-center inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 rounded cursor-pointer ${Class}`}
		class:bg-blue-200={buttonStyle == 'secondary'}
		disabled={disabled}
	/>
{/if}

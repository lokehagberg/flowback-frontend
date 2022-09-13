<script lang="ts">
	export let action = () => {},
		className = '',
		buttonStyle: buttonstyles = 'primary',
		type: buttontypes = 'default',
		disabled = false;

	type buttonstyles = 'primary' | 'secondary';
	type buttontypes = 'default' | 'submit';
</script>

{#if type === 'default'}
	<div
		on:click|preventDefault={action}
		class={`text-center inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 rounded cursor-pointer ${className}`}
		class:bg-blue-200={buttonStyle == 'secondary'}
		{disabled}
	>
		<slot />
	</div>
{:else if type === 'submit'}
	<input
		type="submit"
		class={`text-center inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 rounded cursor-pointer ${className}`}
		class:bg-blue-200={buttonStyle == 'secondary'}
		{disabled}
	/>
{/if}

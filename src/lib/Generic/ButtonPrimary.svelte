<script lang="ts">
	export let action = () => {};
	export let className = '';
	export let buttonStyle: buttonstyles = 'primary';
	export let type: buttontypes = 'default';

	type buttonstyles = 'primary' | 'secondary';
	type buttontypes = 'default' | 'submit';
	//TODO have a series of if statements for different types of buttons like secondary or inputs etc
	//className = "text-cecnter"
	//if (secondary) className += "bg-blue-300"
	//if (primary) className += "bg-blue-600"
</script>

{#if type === 'default'}
	<div
		on:click|preventDefault={action}
		class={`text-center inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 rounded cursor-pointer ${className}`}
		class:bg-blue-200={buttonStyle == 'secondary'}
	>
		<slot />
	</div>
{:else if type === 'submit'}
	<input
		type="submit"
		class={`text-center inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 rounded cursor-pointer ${className}`}
		class:bg-blue-200={buttonStyle == 'secondary'}
	/>
{/if}

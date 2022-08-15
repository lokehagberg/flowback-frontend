<script lang="ts">
	export let action = () => {};
	export let className = ""
	export let buttonType = "primary"
</script>

<div
	on:click|preventDefault={action}
	class={`text-center inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 rounded cursor-pointer ${className}`}
	class:bg-blue-200={buttonType == "secondary"}
>
	<slot />
</div>

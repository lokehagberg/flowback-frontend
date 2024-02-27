<script lang="ts">
	import type { Tag } from "./interface";

	export let tag: Tag,
		Class: string = '',
		onclick = () => {};
</script>

<!-- {@debug tag} -->
<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	class={'select-none text-xs tag text-center bg-gray-400 text-white pl-4 pr-4 pt-1 pb-1 break-words rounded ' +
		Class}
	on:click={onclick}
>
	{tag?.name}
</div>

<style>
	.tag {
		transition: background-color 400ms cubic-bezier(0.075, 0.82, 0.165, 1);
	}
</style>

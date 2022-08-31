<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faBars } from '@fortawesome/free-solid-svg-icons/faBars';

	export let title: string;
	export let description: string;
	export const id:number = 0;
	let isHoveredOver = false;
</script>

<div
	class="select-none hover:shadow-2xl proposal cursor-move flex items-center bg-white gap-8 p-4 border border-gray-200 lg:h-60 xl:h-40"
	on:dragenter|preventDefault={() => (isHoveredOver = true)}
	on:dragleave|preventDefault={() => (isHoveredOver = false)}
	class:hidden={isHoveredOver}
>
	<div><Fa icon={faBars} /></div>
	<div class="h-full">
		<h1 class="text-lg text-left">{title}</h1>
		<p class="text-sm mt-2">
			{description}
		</p>
	</div>
	<slot name="right-icons" />
</div>

<style>
</style>

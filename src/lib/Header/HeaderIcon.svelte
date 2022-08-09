<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faCircle } from '@fortawesome/free-solid-svg-icons/faCircle';
	export let icon = faCircle;
	export let text = 'icon';
	export let href = '/';

	let isHovering = false;
</script>

<div
	on:mouseover={() => (isHovering = true)}
	on:mouseleave={() => (isHovering = false)}
	on:focus
	on:click={() => (window.location.href = "/" + href)}
	class="p-1 relative cursor-pointer"
>
	<div><Fa {icon} primaryColor={isHovering ? 'blue' : 'black'} /></div>
	<div
		class="pt-0.5 pb-0.5 bg-white mt-2 border border-gray-400 rounded text-sm header-icon"
		class:invisible={!isHovering}
		style=""
	>
		{text}
	</div>
</div>

<style>
	.header-icon {
		position: absolute;
		width: 100px;
		left: calc(50% - 50px);
		text-align: center;
		filter: opacity(0.8);
	}
</style>

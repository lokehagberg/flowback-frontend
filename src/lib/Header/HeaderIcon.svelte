<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faCircle } from '@fortawesome/free-solid-svg-icons/faCircle';
	// import { onMount } from 'svelte/types/runtime/internal/lifecycle';
	export let icon = faCircle;
	export let text = 'icon';
	export let href = '/';

	let hovering = false;
	let selectedPage = false;
	
	function checkIfSelected() {
		selectedPage = window.location.pathname === '/' + href;
	};
</script>

<a
	on:mouseover={() => (hovering = true)}
	on:mouseleave={() => (hovering = false)}
	on:focus
	href={"/" + href}
	class="p-5 relative cursor-pointer"
>
	<div on:load={checkIfSelected}>
		<Fa {icon} color={hovering ? '#015BC0' : selectedPage ? 'lightgray' : 'black'} />
	</div>
	<div
		class="text-black p-1 bg-white mt-4 border border-gray-400 rounded text-sm header-icon z-50"
		class:invisible={!hovering}
		style=""
	>
		{text}
	</div>
</a>

<style>
	.header-icon {
		position: absolute;
		width: 100px;
		left: calc(50% - 50px);
		text-align: center;
		filter: opacity(0.8);
	}
</style>

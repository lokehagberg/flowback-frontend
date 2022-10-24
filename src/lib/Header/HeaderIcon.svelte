<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faCircle } from '@fortawesome/free-solid-svg-icons/faCircle';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';

	export let icon = faCircle;
	export let text = 'icon';
	export let href = '/';
	export let Class = '';
	export let color = '';
	export let size = 'xl';

	let hovering = false;
	let selectedPage = false;

	onMount(() => {
		checkIfSelected()
	})

	function checkIfSelected() {
		console.log(window.location.pathname, '/' + href)
		selectedPage = window.location.pathname === '/' + href;
	}
</script>

<a
	on:mouseover={() => (hovering = true)}
	on:mouseleave={() => (hovering = false)}
	on:focus
	href={'/' + href}
	class={`p-4 relative cursor-pointer ${Class}`}
>
	<div on:load={checkIfSelected}>
		<Fa
			{icon}
			{size}
			color={color !== '' ? color : selectedPage ? 'lightgray' : hovering ? '#015BC0' : 'black'}
		/>
	</div>
	<div
		class="text-black p-1 bg-white mt-4 border border-gray-400 rounded text-sm header-icon z-50"
		class:invisible={!hovering}
		style=""
	>
		{$_(text)}
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

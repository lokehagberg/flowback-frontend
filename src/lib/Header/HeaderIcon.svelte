<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faCircle } from '@fortawesome/free-solid-svg-icons/faCircle';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';

	export let icon = faCircle,
		icons = [faCircle];
	if (icons.length === 1) icons[0] = icon;

	export let text = 'icon',
		href = '/',
		Class = '',
		color = '',
		size = 'xl';

	let hovering = false;
	let selectedPage = false;

	onMount(() => {
		checkIfSelected();
	});

	function checkIfSelected() {
		console.log(window.location.pathname, '/' + href);
		selectedPage = window.location.pathname === '/' + href;
	}
</script>

<a
	on:mouseover={() => (hovering = true)}
	on:mouseleave={() => (hovering = false)}
	on:focus
	href={href === "/" ? window.location.href : '/' + href}
	class={`p-4 relative cursor-pointer ${Class}`}
>
	<div on:load={checkIfSelected}>
		{#each icons as icon}
			<Fa
				{icon}
				{size}
				class="inline"
				color={color !== '' ? color : selectedPage ? 'lightgray' : hovering ? '#015BC0' : 'black'}
			/>
		{/each}
	</div>
	<div
		class="text-black p-1 bg-white mt-4 border border-gray-400 rounded text-sm header-icon z-50"
		class:invisible={!hovering}
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

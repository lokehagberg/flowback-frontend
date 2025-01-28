<script lang="ts">
	//TODO: The <HeaderIcon> component should handle default darkMode
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faCircle } from '@fortawesome/free-solid-svg-icons/faCircle';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';
	import { stringify } from 'postcss';

	export let icon = faCircle,
		icons = [faCircle],
		text = 'icon',
		href: string | null = null,
		Class = '',
		color = '',
		size = 'xl',
		tabindex = 0,
		selectedHref: string | null;

	let hovering = false,
		selectedPage = false;

	$: selectedPage = selectedHref === href;

	const handleClick = () => {
		selectedHref = href;
	};

	const checkIfSelected = () => {
		selectedPage = window.location.pathname === '/' + href;
	};

	if (icons.length === 1) icons[0] = icon;

	onMount(() => {
	 	checkIfSelected();
	});
</script>

{#if href}
	<a
		on:mouseover={() => (hovering = true)}
		on:mouseleave={() => (hovering = false)}
		on:focus={() => (hovering = true)}
		on:blur={() => (hovering = false)}
		on:click={handleClick}
		href={href === '/' ? window.location.href : '/' + href}
		class={`relative cursor-pointer ${selectedPage ? `active-icon` : ''} ${Class}`}
		id={href}
		{tabindex}
	>
		<div on:load={checkIfSelected}>
			{#each icons as icon}
				<Fa
					{icon}
					{size}
					class={`inline ${selectedPage ? 'lightgray' : hovering ? '#015BC0' : 'black'}`}
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
{:else}
	<button
		on:mouseover={() => (hovering = true)}
		on:mouseleave={() => (hovering = false)}
		on:focus={() => (hovering = true)}
		on:blur={() => (hovering = false)}
		aria-haspopup="true"
		class={`relative cursor-pointer ${selectedPage ? 'active-icon' : ''} ${Class}`}
		id={href}
	>
		<div on:load={checkIfSelected}>
			{#each icons as icon}
				<Fa
					{icon}
					{size}
					class={`inline ${selectedPage ? 'lightgray' : hovering ? '#015BC0' : 'black'}`}
				/>
			{/each}
		</div>
		<div
			class="text-black p-1 bg-white mt-4 border border-gray-400 rounded text-sm header-icon z-50"
			class:invisible={!hovering}
		>
			{$_(text)}
		</div>
	</button>
{/if}

<style>
	.header-icon {
		position: absolute;
		width: 100px;
		left: calc(50% - 50px);
		text-align: center;
		filter: opacity(0.8);
	}

	.active-icon {
		color: #015BC0;
		position: relative;
	}

	.active-icon::after {
		content: '';
		position: absolute;
		bottom: -1.5rem;
		left: 50%;
		transform: translateX(-50%);
		width: 4rem;
		height: 2px;
		background-color: #015BC0;
	}
</style>

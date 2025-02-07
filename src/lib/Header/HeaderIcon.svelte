<script lang="ts">
	//TODO: The <HeaderIcon> component should handle default darkMode
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faCircle } from '@fortawesome/free-solid-svg-icons/faCircle';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import type { IconDefinition } from '@fortawesome/free-solid-svg-icons';
	import { darkModeStore } from '$lib/Generic/DarkMode';

	export let icon: IconDefinition | string = faCircle,
		icons: (IconDefinition | string)[] = [faCircle],
		text = 'icon',
		href: string | null = null,
		Class = '',
		color = '',
		size = 'xl',
		tabindex = 0,
		selectedHref: string | null = null;

	let hovering = false,
		selectedCurrent = '',
		selectedPage = false,
		darkMode = false;

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
		darkModeStore.subscribe((_darkMode) => {
			darkMode = _darkMode;
		});
	});

	$: if ($page.url.pathname) checkIfSelected();

	const getIconFilter = (isSelected: boolean) => {
		if (darkMode)
			return 'invert(31%) sepia(100%) saturate(10000%) hue-rotate(200deg) brightness(150%) contrast(80%)';
		else if (isSelected)
			return 'invert(31%) sepia(93%) saturate(1410%) hue-rotate(197deg) brightness(91%) contrast(101%)'; // #015BC0
		else return 'brightness(0)';
	};
</script>

{#if href}
	<a
		on:mouseover={() => (hovering = true)}
		on:mouseleave={() => (hovering = false)}
		on:focus={() => (hovering = true)}
		on:blur={() => (hovering = false)}
		on:click={handleClick}
		href={href === '/' ? window.location.href : '/' + href}
		class:active-icon={selectedPage}
		class={`relative transition-all w-14${Class}`}
		id={href}
		{tabindex}
	>
		<div on:load={checkIfSelected} class="flex flex-col items-center">
			{#each icons as icon}
				{#if typeof icon === 'string'}
					{#key darkMode}
						<img
							class="w-6 transition-all"
							style="filter: {getIconFilter(selectedPage)}"
							src={icon}
							alt="icon"
						/>
					{/key}
				{:else}
					<Fa
						{icon}
						{size}
						class={`inline ${selectedPage ? 'lightgray' : selectedPage ? '#015BC0' : 'black'}`}
					/>
				{/if}
				<div class="text-xs mt-2">
					{$_(text)}
				</div>
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
		color: var(--primary);
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
		background-color: var(--primary);
	}

	/* Add smooth transition for color changes */
	img {
		transition: filter 0.2s ease-in-out;
	}
</style>

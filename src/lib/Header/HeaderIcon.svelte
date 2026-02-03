<script lang="ts">
	//TODO: The <HeaderIcon> component should handle default darkMode
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faCircle } from '@fortawesome/free-solid-svg-icons/faCircle';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';
	import { page } from '$app/state';
	import type { IconDefinition } from '@fortawesome/free-solid-svg-icons';
	import { darkModeStore, getIconFilter } from '$lib/Generic/DarkMode';
	import { chatOpenStore } from '$lib/Chat/functions';
	import { goto } from '$app/navigation';

	export let icon: IconDefinition | string = faCircle,
		icons: (IconDefinition | string)[] = [faCircle],
		text = 'icon',
		href: string | null = null,
		Class = '',
		size = 'xl',
		tabindex = 0,
		selectedHref: string | null = null,
		textClass = '',
		disableTextOnHover = false;

	let hovering = false,
		selectedPage = false;

	$: selectedPage = selectedHref === href;

	const handleClick = () => {
		selectedHref = href;
		goto(href === '/' ? window.location.href : '/' + href);
		// Closes chat if clicking one of the Header symbol
		chatOpenStore.set(false);
	};

	const checkSelectedPage = () => {
		selectedPage = window.location.pathname === '/' + href;
	};

	if (icons.length === 1) icons[0] = icon;

	onMount(() => {
		checkSelectedPage();
	});

	$: if (page.url.pathname) checkSelectedPage();
</script>

{#if href}
	<!-- href={href === '/' ? window.location.href : '/' + href} -->
	<button
		on:mouseover={() => (hovering = true)}
		on:mouseleave={() => (hovering = false)}
		on:focus={() => (hovering = true)}
		on:blur={() => (hovering = false)}
		on:click={handleClick}
		class:active-icon={selectedPage}
		class={`relative w-14 ${Class} ${$darkModeStore ? 'text-white' : ''}`}
		id={href}
		{tabindex}
	>
		<div on:load={checkSelectedPage} class="flex flex-col items-center">
			{#key $darkModeStore}
				{#each icons as icon}
					{#if typeof icon === 'string'}
						<img
							class={`w-${size}`}
							style="filter: {getIconFilter(selectedPage)}"
							src={icon}
							alt="icon"
						/>
					{:else}
						<Fa
							{icon}
							{size}
							class={`inline ${selectedPage ? 'lightgray' : selectedPage ? '#015BC0' : 'black'}`}
						/>
					{/if}
					<div class={`${textClass} text-xs mt-2 dark:text-darkmodeText`}>
						{$_(text)}
					</div>
				{/each}
			{/key}
		</div>
		<div
			class="text-black p-1 bg-white mt-4 border border-gray-400 rounded text-sm header-icon z-50"
			class:invisible={!hovering || disableTextOnHover}
		>
			{$_(text)}
		</div>
	</button>
{:else}
	<!-- These are typically applied on pollthumbnail and threadthumbnail -->

	<button
		on:mouseover={() => (hovering = true)}
		on:mouseleave={() => (hovering = false)}
		on:focus={() => (hovering = true)}
		on:blur={() => (hovering = false)}
		aria-haspopup="true"
		class={`flex relative cursor-pointer ${selectedPage ? 'active-icon' : ''} ${Class} ${
			$darkModeStore ? 'text-white' : ''
		}`}
		id={href}
		on:load={checkSelectedPage}
	>
		{#each icons as icon}
			<Fa
				{icon}
				{size}
				class={`inline ${selectedPage ? 'lightgray' : hovering ? '#015BC0' : 'black'}`}
			/>
		{/each}

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

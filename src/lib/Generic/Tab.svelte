<script lang="ts">
	import { _ } from 'svelte-i18n';
	export let selectedPage: string,
		tabs: string[],
		Class: string = '',
		displayNames: string[] = tabs;
</script>

<div class={`flex justify-around w-full mt-2 border-b ${Class}`}>
	{#each tabs as tab, i}
		<button
			class="cursor-pointer border-blue-500 px-4 pb-2 text-center text-xl font-light text-gray-500 dark:text-darkmodeText dark:bg-darkobject"
			class:border-b-2={selectedPage === tab}
			on:click={() => (selectedPage = tab)}
			type="button"
		>
			{$_(displayNames[i])}
		</button>
	{/each}
</div>

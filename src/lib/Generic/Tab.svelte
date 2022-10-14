<script lang="ts">
	import { _ } from 'svelte-i18n';
	export let selectedPage: string;
	export let tabs: string[];
</script>

<div class="flex justify-around w-full mt-2 border-b">
	{#each tabs as tab}
		<div
			class="cursor-pointer border-blue-500 pb-2 text-center text-xl font-light text-gray-500"
			class:border-b-2={selectedPage === tab}
			on:click={() => (selectedPage = tab)}
		>
			{$_(tab)}
		</div>
	{/each}
</div>

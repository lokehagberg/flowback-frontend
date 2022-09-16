<script lang="ts">
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { onMount } from 'svelte';

	export let name: string, description: string, joined: boolean;

	onMount(() => {
		console.log(name);
	});
</script>

<div
	on:click={() => (window.location.href = '/groups/1')}
	class="w-1/2 bg-white relative shadow-md hover:outline vote-thumbnail cursor-pointer"
>
	<!-- <img class="h-2" src="./Logo.png" alt="profile-pic for we hate lithuania for no reason" />
        <img src="./Logo.png" alt="banner for We hate lithuania for no reason" /> -->
	<div class="w-full h-32 bg-red-500" />
	<div class="absolute w-20 h-20 bg-blue-500 top-6 left-6" />
	<div class="flex flex-col gap-6">
		<h1 class="text-2xl p-4 pl-6 text-left">{name}</h1>
		<p class="pb-6 pl-6 pr-6">
			{description}
		</p>
		<ButtonPrimary disabled={!joined} className="">Join</ButtonPrimary>
	</div>
</div>

<style>
	.vote-thumbnail:hover {
		outline: 2px #ccc solid;
	}
</style>

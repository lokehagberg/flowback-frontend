<script lang="ts">
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import { onMount } from 'svelte';

	export let user: any,
		//TODO: Always display username, replace all instance of username with this file
		displayName = false,
		Class = '';

	onMount(() => {
		console.log(`${import.meta.env.VITE_API}/api${user.profile_image}`, 'HELLOO');
	});
</script>

<!-- TODO: Simplify this function to only take images as input or include name -->
<div class={Class}>
	{#if user?.profile_image}
		<img
			src={`${import.meta.env.VITE_API}/api${user.profile_image}`}
			alt="avatar"
			class={`w-10 h-10 rounded-full`}
		/>
	{:else if user?.image}
		<img
			src={`${import.meta.env.VITE_API}/api${user.image}`}
			alt="avatar"
			class={`w-10 h-10 rounded-full`}
		/>
	{:else}
		<img src={DefaultPFP} alt="avatar" class={`w-10 h-10 rounded-full`} />
	{/if}

	<!-- TODO: Make default name default on everywhere-->
	{#if displayName}
		{user?.username}
	{/if}
</div>

<style>
	/* Not used in this file but can be used by the exported class variable */
	.small-pfp > img {
		padding: 10px;
	}
</style>

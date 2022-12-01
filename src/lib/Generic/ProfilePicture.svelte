<script lang="ts">
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	export let user: any,
		//TODO: Always display username, replace all instance of username with this file
		displayName = false,
		notification:boolean|undefined = false;
</script>

{#if notification}
	<div class="bg-purple-400 p-1 rounded-full" />
{/if}

<!-- TODO: Simplify this function to only take images as input or include name -->
{#if user.profile_image}
	<img
		src={`${import.meta.env.VITE_API}${user.profile_image}`}
		alt="avatar"
		class="w-10 h-10 rounded-full"
	/>
{:else if user.image}
	<img
		src={`${import.meta.env.VITE_API}${user.image}`}
		alt="avatar"
		class="w-10 h-10 rounded-full"
	/>
{:else}
	<img src={DefaultPFP} alt="avatar" class="w-10 h-10 rounded-full" />
{/if}

<!-- TODO: Make default name default on everywhere-->
{#if displayName}
	{user.username}
{/if}

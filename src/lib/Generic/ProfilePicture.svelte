<script lang="ts">
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import {env} from "$env/dynamic/public";

	export let user: any,
		//TODO: Always display username, replace all instance of username with this file
		displayName = false,
		Class = '';
</script>

<!-- TODO: Simplify this function to only take images as input or include name -->
<div class={Class}>
	{#if user?.profile_image}
		<img
			src={`${env.PUBLIC_API_URL}${
				env.PUBLIC_IMAGE_HAS_API === 'TRUE' ? '/api' : ''
			}${user.profile_image}`}
			alt="avatar"
			class={`w-10 h-10 rounded-full`}
		/>
	{:else if user?.image}
		<img
			src={`${env.PUBLIC_API_URL}${
				env.PUBLIC_IMAGE_HAS_API === 'TRUE' ? '/api' : ''
			}${user.image}`}
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

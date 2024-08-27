<script lang="ts">
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import { env } from '$env/dynamic/public';

	export let username = '',
		profilePicture: string | null = null,
		//TODO: Always display username, replace all instance of username with this file
		displayName = false,
		Class = '',
		size = 6;
</script>

<div class={`flex gap-2 ${Class}`}>
	{#if profilePicture === null}
		<img src={DefaultPFP} alt="avatar" class={`w-${size} h-${size} rounded-full`} />
	{:else}
		<img
			src={`${env.PUBLIC_API_URL}${
				env.PUBLIC_IMAGE_HAS_API === 'TRUE' ? '/api' : ''
			}${profilePicture}`}
			alt="avatar"
			class={`w-${size} h-${size} rounded-full`}
		/>
	{/if}

	{#if displayName}
		{username}
	{/if}
</div>

<style>
	/* Not used in this file but can be used by the exported class variable */
	.small-pfp > img {
		padding: 10px;
	}
</style>

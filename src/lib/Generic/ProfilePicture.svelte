<script lang="ts">
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import { env } from '$env/dynamic/public';

	export let username = '',
		profilePicture: string | null = null,
		//TODO: Always display username, replace all instance of username with this file
		displayName = false,
		Class = '',
		size:number|null = null;
</script>

<div class={`flex gap-2 ${Class} w-[${size}px] h-[${size}px]`}>
	{#if profilePicture === null}
		<img src={DefaultPFP} alt="avatar" class={`max-w-[${size}px] max-h-[${size}px] rounded-full`} />
	{:else}
		<img
			src={`${env.PUBLIC_API_URL}${
				env.PUBLIC_IMAGE_HAS_API === 'TRUE' ? '/api' : ''
			}${profilePicture}`}
			alt="avatar"
			class={`w-[40px] h-[40px] rounded-full`}
		/>
	{/if}

	{#if displayName}
		<span class="max-w-[150px] overflow-hidden whitespace-nowrap overflow-ellipsis">{username}</span
		>
	{/if}
</div>

<style>
	/* Not used in this file but can be used by the exported class variable */
	.small-pfp > img {
		/* padding: 10px; */
	}
</style>

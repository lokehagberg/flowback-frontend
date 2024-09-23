<script lang="ts">
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import { env } from '$env/dynamic/public';

	export let username = '',
		profilePicture: string | null = null,
		//TODO: Always display username, replace all instance of username with this file
		displayName = false,
		Class = '',
		//TODO: Fix so one can use size
		size:number|null = null;
</script>

<div class={`flex gap-2 items-center ${Class}`}>
	{#if profilePicture === null}
		<img src={DefaultPFP} alt="avatar" class={`w-[40px] h-[40px] rounded-full`} />
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


<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import { onMount } from 'svelte';

	export let user: any = null,
		username = '',
		profilePicture = '',
		//TODO: Always display username, replace all instance of username with this file
		displayName = false,
		Class = '',
		size = 6

	onMount(() => {
		if (!user) getUser();
	});

	//TODO: Make sure get user doesn't get called from multiple profile picture requests at once.
	const getUser = async () => {
		const { res, json } = await fetchRequest('GET', 'user');
		if (res.ok) user = json.results;
	};
</script>

<!-- TODO: Simplify this function to only take images as input or include name -->
<div class={`flex gap-2 ${Class}`}>
	{#if user?.profile_image}
		<img
			src={`${import.meta.env.VITE_API}${
				import.meta.env.VITE_IMAGE_HAS_API === 'TRUE' ? '/api' : ''
			}${user.profile_image}`}
			alt="avatar"
			class={`w-${size} h-${size} rounded-full`}
		/>
	{:else if profilePicture}
		<img
			src={`${import.meta.env.VITE_API}${
				import.meta.env.VITE_IMAGE_HAS_API === 'TRUE' ? '/api' : ''
			}${profilePicture}`}
			alt="avatar"
			class={`w-${size} h-${size} rounded-full`}
		/>
	{:else if user?.image}
		<img
			src={`${import.meta.env.VITE_API}${
				import.meta.env.VITE_IMAGE_HAS_API === 'TRUE' ? '/api' : ''
			}${user.image}`}
			alt="avatar"
			class={`w-${size} h-${size} rounded-full`}
		/>
	{:else}
		<img src={DefaultPFP} alt="avatar" class={`w-${size} h-${size} rounded-full`} />
	{/if}

	<!-- TODO: Make default name default on everywhere-->
	{#if displayName}
		{#if user?.username}
			{user?.username}
		{:else}
			{username}
		{/if}
	{/if}
</div>

<style>
	/* Not used in this file but can be used by the exported class variable */
	.small-pfp > img {
		padding: 10px;
	}
</style>

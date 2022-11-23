<script lang="ts">
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	
	export let user: any;
</script>

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

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import type { Group } from 'src/routes/groups/interfaces';

	export let group: Group;
</script>

<div class="w-1/2 bg-white relative shadow-md hover:outline vote-thumbnail cursor-pointer">
	<div on:click={() => (window.location.href = '/groups/1')}>
		<img src={`${import.meta.env.VITE_API}${group.cover_image}`} class="w-full h-32" alt="cover"/>
		<img src={`${import.meta.env.VITE_API}${group.image}`} class="absolute w-20 h-20 top-6 left-6" alt="profile"/>
	</div>
	<div class="flex flex-col gap-6">
		<h1 class="text-2xl p-4 pl-6 text-left" on:click={() => (window.location.href = '/groups/1')}>
			{group.name}
		</h1>
		<p class="pb-6 pl-6 pr-6" on:click={() => (window.location.href = '/groups/1')}>
			{group.description}
		</p>
		<ButtonPrimary
			action={async () => {
				const res = await fetchRequest('POST', `group/${group.id}/${group.joined ? "leave" : "join"}`, {})
				if (res.ok) group.joined = !group.joined
			}}
			className="hover:bg-blue-800"
			>{group.joined ? 'Leave' : 'Join'}</ButtonPrimary
		>
	</div>
</div>

<style>
	.vote-thumbnail:hover {
		outline: 2px #ccc solid;
	}
</style>

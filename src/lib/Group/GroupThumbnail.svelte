<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import type { Group } from './interface';
	import { _ } from 'svelte-i18n';

	export let group: Group;

	const goToGroup = () => {
		window.location.href = `/groups/${group.id}`;
	};
</script>

<div on:click={goToGroup}
	class="w-5/6 md:w-1/2 bg-white relative shadow-md vote-thumbnail cursor-pointer rounded-2xl"
>
	<div on:click={goToGroup}>
		<img
			src={`${import.meta.env.VITE_API}${group.cover_image}`}
			class="cover rounded-t-2xl"
			alt="cover"
		/>
	</div>
	<img
		src={`${import.meta.env.VITE_API}${group.image}`}
		class="bg-white rounded-full inline w-[100px] h-[100px] absolute left-1/2 -translate-x-1/2 -translate-y-1/2"
		alt="profile"
	/>

	<div on:click={goToGroup} >
		<h1 class="text-2xl p-4 text-left mt-10 text-center">
			{group.name}
		</h1>
		<p class="pl-6 pr-6 pb-6">
			{group.description}
		</p>
	</div>

	<div class="flex justify-center mb-6">
		<ButtonPrimary
			action={async () => {
				const { res } = await fetchRequest(
					'POST',
					`group/${group.id}/${group.joined ? 'leave' : 'join'}`,
					{}
				);
				if (res.ok) group.joined = !group.joined;
			}}
			Class="hover:bg-blue-800 2xl:pt-6 2xl:pb-6 "
			>{$_(group.joined ? 'Leave' : 'Join')}</ButtonPrimary
		>
	</div>
</div>

<style>
	.vote-thumbnail:hover {
		outline: 2px #ccc solid;
	}

	img.cover {
		aspect-ratio: 4;
		width: 100%;
	}
</style>

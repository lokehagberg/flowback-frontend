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

<div
	class="w-5/6 md:w-1/2 bg-white relative shadow-md vote-thumbnail cursor-pointer rounded-2xl"
>
	<div on:click={goToGroup}>
		<img
			src={`${import.meta.env.VITE_API}${group.cover_image}`}
			class="cover rounded-t-2xl"
			alt="cover"
		/>
		<img
			src={`${import.meta.env.VITE_API}${group.image}`}
			class="absolute top-6 left-6 profile"
			alt="profile"
		/>
	</div>

	<div on:click={goToGroup} >
		<h1 class="text-2xl p-4 pl-6 text-left">
			{group.name}
		</h1>
		<p class="pb-6 pl-6 pr-6">
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

	img.profile {
		width: 100px;
		height: 100px;
	}
</style>

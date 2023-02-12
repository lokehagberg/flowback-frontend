<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import type { Group } from './interface';
	import { _ } from 'svelte-i18n';

	export let group: Group;
	let pending = false;

	const goToGroup = () => {
		if (group.joined) window.location.href = `/groups/${group.id}`;
	};

	const subscribeToGroup = async () => {
		const {res, json} = await fetchRequest('POST', 'notification/group')
	}
</script>

<div
	on:click={goToGroup}
	class={`w-4/6 md:w-2/5 bg-white relative shadow-md ${
		group.joined && 'cursor-pointer hover:shadow-xl vote-thumbnail'
	} transition-shadow rounded-2xl`}
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

	<div on:click={goToGroup}>
		<h1 class="text-2xl p-4 text-left mt-10 text-center">
			{group.name}
		</h1>
		<p class="pl-6 pr-6 pb-6">
			{group.description}
		</p>
	</div>

	<div class="flex justify-center mb-6">
		{#if !group.joined && pending === false}
			<ButtonPrimary
				action={async () => {
					if (!group.direct_join) {
						pending = true;
						return;
					}

					const { res } = await fetchRequest('POST', `group/${group.id}/join`, {});
					if (res.ok) {
						group.joined = !group.joined;
						goToGroup();
					}
				}}
				Class="hover:bg-blue-800 bg-blue-600"
				>{$_(group.joined ? 'Leave' : group.direct_join ? 'Join' : 'Ask to join')}</ButtonPrimary
			>
		{:else if pending === true}
			<div>{$_('Pending invite')}</div>
		{/if}
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

<script lang="ts">
	import { goto } from '$app/navigation';
	import { becomeMemberOfGroup } from '$lib/Blockchain/javascript/rightToVote';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { Group } from './interface';
	import { _ } from 'svelte-i18n';
	import DefaultBanner from '$lib/assets/default_banner_group.png';
	import { onThumbnailError } from '$lib/Generic/GenericFunctions';
	import {env} from "$env/dynamic/public";

	export let group: Group;
	let pending: boolean = false;

	const goToGroup = () => {
		if (group.joined) goto(`/groups/${group.id}`);
	};

	const subscribeToGroup = async () => {
		const { res, json } = await fetchRequest('POST', 'notification/group');
	};

	const joinGroup = async () => {
		const { res } = await fetchRequest('POST', `group/${group.id}/join`, { to: group.id });
		if (res.ok) {
			group.joined = !group.joined;
			if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE')
				becomeMemberOfGroup(group.blockchain_id);
			if (group.direct_join) goToGroup();
		}
	};
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	on:click={goToGroup}
	on:keydown
	class={`w-4/6 md:w-2/5 max-w-[650px] bg-white relative shadow-md dark:bg-darkobject dark:text-darkmodeText ${
		group.joined && 'cursor-pointer hover:shadow-xl vote-thumbnail'
	} transition-shadow rounded-2xl`}
>
	<div on:click={goToGroup} on:keydown>
		<img
			src={`${env.PUBLIC_API_URL}${
				env.PUBLIC_IMAGE_HAS_API === 'TRUE' ? '/api' : ''
			}${group.cover_image}`}
			class="cover rounded-t-2xl"
			alt="cover"
			on:error={(e) => onThumbnailError(e, DefaultBanner)}
		/>
	</div>
	<img
		src={`${env.PUBLIC_API_URL}${
			env.PUBLIC_IMAGE_HAS_API === 'TRUE' ? '/api' : ''
		}${group.image}`}
		class="bg-white rounded-full inline w-[100px] h-[100px] absolute left-1/2 -translate-x-1/2 -translate-y-1/2"
		on:error={(e) => onThumbnailError(e, DefaultBanner)}
		alt="profile"
	/>

	<div on:click={goToGroup} on:keydown>
		<h1 class="text-2xl p-4 mt-10 text-center">
			{group.name}
		</h1>
		<p class="pl-6 pr-6 pb-6 break-words">
			{group.description}
		</p>
	</div>

	<div class="flex justify-center mb-6">
		{#if !group.joined && pending === false}
			<Button action={joinGroup} Class="hover:bg-blue-800 bg-blue-600"
				>{$_(group.joined ? 'Leave' : group.direct_join ? 'Join' : 'Ask to join')}</Button
			>
		{:else if pending}
			<div>{$_('Pending invite')}</div>
		{/if}
	</div>
</div>

<style>
	.vote-thumbnail:hover {
		outline: 2px #ccc solid;
	}

	img.cover {
		aspect-ratio: 5;
		width: 100%;
	}
</style>

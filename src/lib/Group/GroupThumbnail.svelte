<script lang="ts">
	import { goto } from '$app/navigation';
	import { becomeMemberOfGroup } from '$lib/Blockchain_v1_Ethereum/javascript/rightToVote';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { Group } from './interface';
	import { _ } from 'svelte-i18n';
	import DefaultBanner from '$lib/assets/default_banner_group.png';
	import { onThumbnailError } from '$lib/Generic/GenericFunctions';
	import { env } from '$env/dynamic/public';
	import type { poppup } from '$lib/Generic/Poppup';
	import Poppup from '$lib/Generic/Poppup.svelte';

	export let group: Group;

	let pending: boolean = false,
		poppup: poppup = { message: '', success: false };

	const goToGroup = () => {
		if (group.joined) goto(`/groups/${group.id}`);
	};

	const subscribeToGroup = async () => {
		const { res, json } = await fetchRequest('POST', 'notification/group');
	};

	const joinGroup = async (directJoin: boolean) => {
		const { res } = await fetchRequest('POST', `group/${group.id}/join`, { to: group.id });
		if (!res.ok) return;

		if (!directJoin) {
			pending = true;
			poppup = { message: 'Pending invite', success: true };
		}

		group.joined = !group.joined;

		if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE') becomeMemberOfGroup(group.blockchain_id);
	};
</script>

<button
	on:click={goToGroup}
	class={`w-4/6 md:w-2/5 max-w-[650px] bg-white relative shadow-md dark:bg-darkobject dark:text-darkmodeText ${
		group.joined && 'cursor-pointer hover:shadow-xl vote-thumbnail'
	} transition-shadow rounded-2xl`}
>
	<button on:click={goToGroup} class="w-full">
		<img
			src={`${env.PUBLIC_API_URL}${group.cover_image}`}
			class="cover rounded-t-2xl w-full"
			alt="cover"
			on:error={(e) => onThumbnailError(e, DefaultBanner)}
		/>
	</button>
	<img
		src={`${env.PUBLIC_API_URL}${group.image}`}
		class="bg-white rounded-full w-[100px] h-[100px] absolute left-1/2 -translate-x-1/2 -translate-y-1/2"
		on:error={(e) => onThumbnailError(e, DefaultBanner)}
		alt="profile"
	/>

	<button on:click={goToGroup}>
		<h1 class="text-2xl p-4 mt-10 text-center break-words">
			{group.name}
		</h1>
		<!-- <p class="pl-6 pr-6 pb-6 break-words">
			{group.description}
		</p> -->
		{#if group.description.length > 0}
			<div class="my-2 mx-auto w-[85%] min-w-72 grid-area-description break-words">
				<p class="line-clamp-2">{group.description}</p>
			</div>
		{/if}
	</button>

	<div class="flex justify-center mb-6">
		{#if !group.joined && pending === false}
			<Button
				disabled={group.pending_join}
				onClick={() => joinGroup(group.direct_join)}
				Class="hover:bg-blue-800 bg-blue-600"
			>
				{$_(
					group.joined
						? 'Leave'
						: group.direct_join
						? 'Join'
						: group.pending_join
						? 'Request sent'
						: 'Ask to join'
				)}
			</Button>
		{:else if pending}
			<div>{$_('Request sent')}</div>
		{/if}
	</div>
</button>
<Poppup bind:poppup />

<style>
	.vote-thumbnail:hover {
		outline: 2px #ccc solid;
	}

	img.cover {
		aspect-ratio: 5;
		width: 100%;
	}
</style>

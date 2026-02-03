<script lang="ts">
	import { goto } from '$app/navigation';
	import {
		becomeMemberOfGroup,
		removeGroupMembership
	} from '$lib/Blockchain_v1_Ethereum/javascript/rightToVote';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { Group } from './interface';
	import { _ } from 'svelte-i18n';
	import DefaultBanner from '$lib/assets/default_banner_group.png';
	import { onThumbnailError } from '$lib/Generic/GenericFunctions';
	import { env } from '$env/dynamic/public';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import Modal from '$lib/Generic/Modal.svelte';
	import { idfy } from '$lib/Generic/GenericFunctions2';
	import { groupStore } from './Kanban/Kanban';
	import { chatPartnerStore } from '$lib/Chat/functions';

	let { group = $bindable() }: { group: Group } = $props();

	let areYouSureModal = $state(false);

	const goToGroup = (e: event) => {
		if (e.target.id === 'group-join-button') return; // Prevent navigation when clicking the join button

		if (group.joined) goto(`/groups/${group.id}`);
	};

	const joinGroup = async (directJoin: boolean) => {
		const { res } = await fetchRequest('POST', `group/${group.id}/join`, {
			to: group.id
		});

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'An error occurred while joining the group',
				success: false
			});
			return;
		}

		if (!directJoin) {
			group.pending_join = true;
			ErrorHandlerStore.set({ message: 'Pending invite', success: true });
		} else group.joined = !group.joined;

		if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE')
			becomeMemberOfGroup(group.blockchain_id);

		//TODO: Edit groupStore instead of appending dupliucate groups
		groupStore.set([...$groupStore, group]);
	};

	const leaveGroup = async () => {
		const { res, json } = await fetchRequest('POST', `group/${group.id}/leave`);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message:
					json.detail[0] ||
					json.detail ||
					'An error occurred while leaving the group',
				success: false
			});
			return;
		}

		if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE')
			removeGroupMembership(group.id);
		areYouSureModal = false;
		group.joined = false;
		group.pending_join = false;
		groupStore.set($groupStore.filter((g) => g.id !== group.id));
		chatPartnerStore.set(0);
	};
</script>

<button
	id={group.name.toLowerCase().replaceAll(' ', '-')}
	class={`w-4/6 md:w-2/5 max-w-[650px] bg-white relative shadow-md dark:bg-darkobject dark:text-darkmodeText text-center ${
		group.joined && 'cursor-pointer hover:shadow-xl vote-thumbnail'
	} transition-shadow rounded-2xl`}
	onclick={goToGroup}
>
	{#if group.joined}
		<img
			src={`${env.PUBLIC_API_URL}${group.cover_image}`}
			class="cover rounded-t-2xl w-full"
			alt="cover"
			onerror={(e) => onThumbnailError(e, DefaultBanner)}
		/>
	{:else}
		<img
			src={`${env.PUBLIC_API_URL}${group.cover_image}`}
			class="cover rounded-t-2xl w-full"
			alt="cover"
			onerror={(e) => onThumbnailError(e, DefaultBanner)}
		/>
	{/if}
	<img
		src={`${env.PUBLIC_API_URL}${group.image}`}
		class="bg-white rounded-full w-[100px] h-[100px] absolute left-1/2 -translate-x-1/2 -translate-y-1/2"
		onerror={(e) => onThumbnailError(e, DefaultBanner)}
		alt="profile"
	/>

	<h1 class="text-2xl p-4 mt-10 text-center break-words">
		{group.name}
	</h1>

	{#if group.description.length > 0}
		<div
			class="my-2 mx-auto w-[85%] min-w-72 grid-area-description break-words"
		>
			<p class="line-clamp-2">{group.description}</p>
		</div>
	{/if}

	<div class="flex justify-center mb-6">
		{#if !group.pending_join}
			<Button
				disabled={group.pending_join}
				Class="hover:bg-blue-800 bg-blue-600"
				onClick={(e) => {
					// Prevents the button click from triggering the goToGroup function
					e.stopPropagation();

					if (group.joined) {
						areYouSureModal = true;
					} else {
						joinGroup(group.direct_join);
					}
				}}
				id={`join-${idfy(group.name)}`}
			>
				{$_(
					group.joined ? 'Leave' : group.direct_join ? 'Join' : 'Ask to join'
				)}
			</Button>
		{:else}
			{$_('Request sent')}
		{/if}
	</div>
</button>

<Modal
	bind:open={areYouSureModal}
	Class="max-w-[400px]"
	buttons={[
		{ label: 'Yes', type: 'warning', onClick: leaveGroup },
		{ label: 'No', type: 'default', onClick: () => (areYouSureModal = false) }
	]}
>
	>
	<div slot="header">{$_('Are you sure?')}</div>
	<div slot="body">{$_('You are about to leave the group!')}</div>
</Modal>

<style>
	.vote-thumbnail:hover {
		outline: 2px #ccc solid;
	}

	img.cover {
		aspect-ratio: 5;
		width: 100%;
	}
</style>

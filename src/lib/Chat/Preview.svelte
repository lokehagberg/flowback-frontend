<script lang="ts">
	import { type GroupMembers, type invite } from './interfaces';
	import { fetchRequest } from '$lib/FetchRequest';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { onMount } from 'svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import {
		chatOpenStore,
		chatPartnerStore,
		getUserChannelId,
		previewStore
	} from './functions';
	import Button from '$lib/Generic/Button.svelte';
	import { _ } from 'svelte-i18n';
	import UserSearch from '$lib/Generic/UserSearch.svelte';
	import Fa from 'svelte-fa';
	import {
		faArrowRightFromBracket,
		faCircle,
		faPaperPlane
	} from '@fortawesome/free-solid-svg-icons';
	import { elipsis } from '$lib/Generic/GenericFunctions';
	import Modal from '$lib/Generic/Modal.svelte';

	let chatSearch = $state(''),
		openUserSearch = $state(false),
		leaveGroupModal = $state(false),
		leaveGroupChannelId: number | null = $state(null);

	type Props = {
		creatingGroup: boolean;
		inviteList?: invite[];
		groupMembers?: GroupMembers[];
	};

	let {
		creatingGroup = $bindable(),
		inviteList = [],
		groupMembers = []
	}: Props = $props();

	// Handle chat selection and clear notifications
	const clickedChatter = async (chatterId: any) => {
		let preview = $previewStore?.find(
			(_preview) => _preview.channel_id === chatterId
		);

		const { res, json } = await fetchRequest(
			'POST',
			`chat/message/channel/userdata/update`,
			{
				channel_id: chatterId,
				timestamp: new Date()
			}
		);

		if (!res.ok) return;

		// Whenever the user clicks a chatter, remove notification
		if (preview && preview.recent_message) {
			preview.timestamp = new Date().toString();
			preview.recent_message = {
				...preview.recent_message,
				notified: true
			};

			previewStore.update((store) =>
				store ? store?.map((p) => (p.id === preview?.id ? preview : p)) : []
			);
		}

		// $chatPartnerStore = chatterId;
		chatPartnerStore.set(chatterId);
	};

	// Fetch chat invites
	const UserChatInviteList = async () => {
		const { res, json } = await fetchRequest('GET', `user/chat/invite/list`);
		if (!res.ok) return;
		inviteList = json?.results;
	};

	// Accept or reject chat invites
	const UserChatInvite = async (accept: boolean, invite_id: number) => {
		const { res, json } = await fetchRequest('POST', `user/chat/invite`, {
			invite_id,
			accept
		});

		if (!res.ok) return;
		inviteList = inviteList.map((invitee) => {
			if (invitee.id === invite_id) invitee.rejected = !accept;
			return invitee;
		});
	};

	// Leaving user created group chats (scuffed way)
	const leaveGroupScuffed = async (id: number | string) => {
		id = Number(id);

		// TODO: Fix this endpoint to properly leave a group chat
		const { res, json } = await fetchRequest(
			'POST',
			`chat/message/channel/userdata/update`,
			{
				channel_id: id,
				timestamp: '2999-12-31T23:59:59Z',
				closed_at: '2999-12-31T23:59:59Z'
			}
		);

		if (!res.ok) return;

		// Remove the chat from previewStore
		previewStore.update((store) =>
			store ? store?.filter((p) => p.channel_id !== id) : []
		);

		// Clear chatPartnerStore if the user is currently in the left group
		if ($chatPartnerStore === id) {
			chatPartnerStore.set(0);
		}
	};

	onMount(async () => {
		await UserChatInviteList();
		clickedChatter($chatPartnerStore);
	});
</script>

<div class="max-h-[100%] pb-2">
	<div class="border-b-2 w-full">
		<TextInput
			placeholder={'Search chatters'}
			label=""
			max={null}
			bind:value={chatSearch}
			inputClass="mt-4 mb-2 placeholder-gray-600 py-1 pl-2 text-gray-500 border-0 bg-gray-100 dark:bg-darkobject"
		/>
	</div>

	<div class="flex justify-center">
		<Button
			Class="my-2"
			onClick={() => {
				creatingGroup = true;
				groupMembers = []; // Reset groupMembers
			}}
		>
			{$_('+ New Group')}
		</Button>

		<UserSearch bind:showUsers={openUserSearch}>
			<div slot="action" let:item>
				<button
					onclick={async () => {
						const id = await getUserChannelId(item.id);
						chatPartnerStore.set(id);
						chatOpenStore.set(true);
						openUserSearch = false;
					}}
				>
					<Fa icon={faPaperPlane} rotate="60" />
				</button>
			</div>
		</UserSearch>
		<!-- <Button onClick={newDM}>New DM</Button> -->
	</div>

	{#if inviteList}
		{#each inviteList as groupChat}
			{#if !groupChat.rejected && groupChat?.title?.split(',')?.length > 2}
				{#if groupChat.rejected === null}
					<span>{$_("You've been invited to this chat:")}</span>
					<Button onClick={() => UserChatInvite(true, groupChat.id)}
						>{$_('Accept')}</Button
					>
					<Button onClick={() => UserChatInvite(false, groupChat.id)}
						>{$_('Deny')}</Button
					>
				{/if}
				<button
					class="w-full transition transition-color p-3 flex items-center gap-3 cursor-pointer dark:bg-darkobject"
					class:dark:bg-gray-700={$chatPartnerStore ===
						groupChat.message_channel_id}
					class:dark:hover:bg-darkbackground={groupChat.rejected === false}
					class:hover:bg-gray-200={groupChat.rejected === false}
					class:active:bg-gray-500={groupChat.rejected === false}
					class:bg-gray-200={$chatPartnerStore === groupChat.message_channel_id}
					onclick={() => {
						if (groupChat.rejected === false)
							clickedChatter(groupChat.message_channel_id);
					}}
					disabled={groupChat.rejected === null}
				>
					<ProfilePicture
						username={groupChat.message_channel_name}
						profilePicture={null}
					/>
					<div class="flex flex-col max-w-[40%]">
						<span
							class="max-w-full text-left overflow-x-hidden overflow-ellipsis"
						>
							{groupChat.message_channel_name}
						</span>
					</div>
				</button>
			{/if}
		{/each}
	{/if}

	{#each $previewStore as chatter}
		{#if chatter.channel_title
			?.toUpperCase()
			?.includes(chatSearch.toUpperCase()) && ((chatter?.channel_origin_name === 'user' && creatingGroup) || !creatingGroup)}
			<button
				class="w-full transition transition-color p-3 flex items-center gap-3 hover:bg-gray-200 active:bg-gray-500 cursor-pointer dark:bg-darkobject dark:hover:bg-darkbackground"
				class:bg-gray-200={$chatPartnerStore === chatter.channel_id}
				class:dark:bg-gray-700={$chatPartnerStore === chatter.channel_id}
				onclick={() => clickedChatter(chatter.channel_id)}
			>
				<ProfilePicture
					profilePicture={chatter?.recent_message?.profile_image}
				/>

				<div class="flex justify-between items-center w-full">
					<div>
						<div
							class="max-w-full text-left overflow-x-hidden overflow-ellipsis"
						>
							{chatter.channel_title ??
								chatter.recent_message?.channel_title ??
								'Name not found'}
						</div>
						<div class="text-left text-gray-400 text-sm h-[20px]">
							{elipsis(chatter?.recent_message?.message || '', 15)}
						</div>
					</div>
					<!-- <EveryProperty obj={chatter} /> -->
					<!-- Purple dot on Chat indicating notification -->
					{#if chatter?.recent_message?.notified === false}
						<div class="rounded-full text-purple-300">
							<Fa size={'xs'} icon={faCircle} />
						</div>
					{/if}
				</div>
				{#if chatter?.channel_origin_name === 'user_group'}
					<Button
						onClick={() => {
							leaveGroupChannelId = chatter.channel_id;
							leaveGroupModal = true;
						}}
					>
						<Fa icon={faArrowRightFromBracket} />
					</Button>
				{/if}
			</button>
			<!-- Button for creating group user chat -->
			<!-- {#if creatingGroup} -->
			<!-- 	<div id={`chat-${idfy(chatter.channel_title ?? '')}`}> -->
			<!-- 		<Button -->
			<!-- 			onClick={() => { -->
			<!-- 				if (groupMembers.some((member) => member.id === chatter.id)) { -->
			<!-- 					return; -->
			<!-- 				} -->
			<!-- 				const newMember = chatter.participants.find( -->
			<!-- 					(user) => user.id !== $userStore?.id -->
			<!-- 				); -->
			<!-- 				// @ts-ignore -->
			<!-- 				groupMembers = [...groupMembers, newMember]; -->
			<!-- 			}} -->
			<!-- 		> -->
			<!-- 			{$_('Add User')} -->
			<!-- 		</Button> -->
			<!-- 	</div> -->
			<!-- {/if} -->
		{/if}
	{/each}
</div>

<Modal
	bind:open={leaveGroupModal}
	onClose={() => {
		leaveGroupChannelId = null;
	}}
	buttons={[
		{
			label: 'Cancel',
			type: 'default',
			onClick: () => {
				leaveGroupModal = false;
			}
		},
		{
			label: 'Leave',
			type: 'warning',
			onClick: async () => {
				if (leaveGroupChannelId) {
					await leaveGroupScuffed(leaveGroupChannelId);
				}
				leaveGroupModal = false;
			}
		}
	]}
>
	<span slot="header">{$_('Leave Group')}</span>
	<span slot="body"
		>{$_('Are you sure you want to leave this group chat?')}</span
	>
</Modal>

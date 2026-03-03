<script lang="ts">
	import {
		type GroupMembers,
		type invite,
		type PreviewMessage
	} from './interfaces';
	import { fetchRequest } from '$lib/FetchRequest';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { onMount } from 'svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import {
		chatOpenStore,
		chatPartnerStore,
		fixDirectMessageChannelName,
		getUserChannelId,
		previewStore
	} from './functions';
	import { userStore } from '$lib/User/interfaces';
	import Button from '$lib/Generic/Button.svelte';
	import { _ } from 'svelte-i18n';
	import UserSearch from '$lib/Generic/UserSearch.svelte';
	import Fa from 'svelte-fa';
	import {
		faArrowRightFromBracket,
		faPaperPlane
	} from '@fortawesome/free-solid-svg-icons';
	import Modal from '$lib/Generic/Modal.svelte';

	let chatSearch = $state(''),
		openUserSearch = $state(false),
		leaveGroupModal = $state(false),
		leaveGroupChannelId: number | null = $state(null),
		next: string | undefined | null = $state(undefined);

	let previewContainer: HTMLDivElement;

	// Lazy Loading
	const getPreviews = async () => {
		if (next === null) return;

		if (next === undefined) {
			const { res, json } = await fetchRequest(
				'GET',
				`chat/message/channel/preview/list?order_by=timestamp&limit=20`
			);
			if (!res.ok) return;

			let previews = json?.results.map((preview: PreviewMessage) => ({
				...preview,
				recent_message: {
					...preview.recent_message,
					notified:
						preview.recent_message === null ||
						new Date(preview.timestamp) >
							new Date(preview.recent_message?.created_at) ||
						preview.recent_message?.user.id === $userStore?.id
				}
			}));

			fixDirectMessageChannelName(previews, $userStore?.id);
			previewStore.set(previews);
			next = json.next;
		} else {
			const { res, json } = await fetchRequest('GET', next);
			if (!res.ok) return;

			let morePreviews = json?.results.map((preview: PreviewMessage) => ({
				...preview,
				recent_message: {
					...preview.recent_message,
					notified:
						preview.recent_message === null ||
						new Date(preview.timestamp) >
							new Date(preview.recent_message?.created_at) ||
						preview.recent_message?.user.id === $userStore?.id
				}
			}));

			fixDirectMessageChannelName(morePreviews, $userStore?.id);
			previewStore.update((store) => [...(store || []), ...morePreviews]);
			next = json.next;
		}
	};

	const handleScroll = () => {
		if (!previewContainer) return;
		const { scrollTop, clientHeight, scrollHeight } = previewContainer;
		if (scrollTop + clientHeight >= scrollHeight - 1) {
			getPreviews();
		}
	};

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
		await getPreviews();
		clickedChatter($chatPartnerStore);
	});
</script>

<div
	bind:this={previewContainer}
	class="h-full overflow-y-auto pb-2"
	onscroll={handleScroll}
>
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

	{#if inviteList?.some((g) => !g.rejected && g?.title?.split(',')?.length > 2)}
		<p class="text-xs text-gray-400 px-3 pt-2">{$_('Invites')}</p>
	{/if}
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
					class="w-full transition-colors duration-150 px-3 py-2.5 flex items-center gap-3 cursor-pointer rounded-xl mt-1"
					class:dark:bg-gray-700={$chatPartnerStore ===
						groupChat.message_channel_id}
					class:dark:hover:bg-gray-700={groupChat.rejected === false}
					class:hover:bg-gray-100={groupChat.rejected === false}
					class:active:bg-gray-200={groupChat.rejected === false}
					class:bg-gray-100={$chatPartnerStore === groupChat.message_channel_id}
					class:border-l-[3px]={$chatPartnerStore ===
						groupChat.message_channel_id}
					class:border-primary={$chatPartnerStore ===
						groupChat.message_channel_id}
					class:rounded-l-none={$chatPartnerStore ===
						groupChat.message_channel_id}
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
					<div class="min-w-0 flex-1">
						<span class="font-medium text-sm truncate block">
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
				class="w-full transition-colors duration-150 px-3 py-2.5 flex items-center gap-3 cursor-pointer rounded-xl mt-1 hover:bg-gray-100 active:bg-gray-200 dark:hover:bg-gray-700 dark:active:bg-gray-600"
				class:bg-gray-100={$chatPartnerStore === chatter.channel_id}
				class:dark:bg-gray-700={$chatPartnerStore === chatter.channel_id}
				class:border-l-[3px]={$chatPartnerStore === chatter.channel_id}
				class:border-primary={$chatPartnerStore === chatter.channel_id}
				class:rounded-l-none={$chatPartnerStore === chatter.channel_id}
				onclick={() => clickedChatter(chatter.channel_id)}
			>
				<ProfilePicture
					profilePicture={chatter?.recent_message?.profile_image}
				/>

				<div class="flex justify-between items-center w-full min-w-0">
					<div class="min-w-0 flex-1">
						<div class="font-medium text-sm truncate">
							{chatter.channel_title ??
								chatter.recent_message?.channel_title ??
								'Name not found'}
						</div>
						<div class="text-gray-400 text-xs truncate mt-0.5">
							{chatter?.recent_message?.message || ''}
						</div>
					</div>
					<!-- Purple dot on Chat indicating notification -->
					{#if chatter?.recent_message?.notified === false}
						<div class="w-2.5 h-2.5 rounded-full bg-purple-400 shrink-0"></div>
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

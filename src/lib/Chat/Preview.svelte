<script lang="ts">
	import { type GroupMembers, type invite, type PreviewMessage } from './interfaces';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Group } from '$lib/Group/interface';
	import Tab from '$lib/Generic/Tab.svelte';
	import type { User } from '$lib/User/interfaces';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { onMount } from 'svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { chatPreview as chatLimit } from '../Generic/APILimits.json';
	import { chatPartner } from './ChatStore.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { _ } from 'svelte-i18n';
	import { workGroupsStore, type WorkGroup } from '$lib/Group/WorkingGroups/interface';
	import { env } from '$env/dynamic/public';
	import { updateUserData } from './functions';

	let groups: Group[] = [],
		directs: any[] = [],
		user: User,
		chatSearch = '',
		workGroupList: WorkGroup[] = [];

	export let selectedChat: number | null,
		selectedChatChannelId: number | null,
		creatingGroup: boolean,
		selectedPage: 'direct' | 'group' = 'direct',
		previewDirect: PreviewMessage[] = [],
		previewGroup: PreviewMessage[] = [],
		inviteList: invite[] = [],
		groupMembers: GroupMembers[] = [];

	// Reactive variables to track unread messages
	$: hasUnreadDirect = previewDirect.some((p) => p.notified);
	$: hasUnreadGroup = previewGroup.some((p) => p.notified);

	// Fetch and set up preview messages
	const setUpPreview = async () => {
		previewDirect = await getPreview('user');
		previewGroup = await getPreview('group');
	};

	// Fetch preview messages and set notified based on localStorage timestamps
	const getPreview = async (selectedPage: 'user' | 'group') => {
		const { res, json } = await fetchRequest(
			'GET',
			`chat/message/channel/preview/list?origin_name=${selectedPage}`
		);
		if (!res.ok) return [];

		if (selectedPage === 'group')
			return json.results;
		else {
			// Process messages to set notified based on last interaction timestamp
			return json.results.map((message: PreviewMessage) => {
				const timestampKey = `lastInteraction_${message.channel_id}`;
				const lastInteraction = localStorage.getItem(timestampKey);
				// Set notified to true if message is newer than last interaction or no interaction exists
				message.notified = lastInteraction ? new Date(message.created_at) > new Date(lastInteraction) : false;
				// console.log(timestampKey, new Date(message.created_at).toISOString(), new Date(lastInteraction).toISOString());
				return message;
			});
		}
	};

	// Fetch channel ID for a user
	const getChannelId = async (id: number) => {
		const { res, json } = await fetchRequest('GET', `user/chat?target_user_ids=${id}`);
		return json.id;
	};

	// Fetch list of chattable users and groups
	const getChattable = async () => {
		if (directs.length + groups.length !== 0) return;
		directs = await userList();
		groups = await groupList();
	};

	// Fetch list of groups
	const groupList = async () => {
		const { res, json } = await fetchRequest('GET', `group/list?joined=true&limit=${chatLimit}`);
		if (!res.ok) return [];
		return json.results;
	};

	// Fetch list of users
	const userList = async () => {
		const { json, res } = await fetchRequest('GET', `users?limit=${chatLimit}`);
		if (!res.ok) return [];
		let chatters = json.results.filter((chatter: any) => chatter.id !== user.id);
		chatters = await Promise.all(
			chatters.map(async (chatter: any) => {
				chatter.channel_id = await getChannelId(chatter.id);
				return chatter;
			})
		);
		return chatters;
	};

	// Handle chat selection and clear notifications
	const clickedChatter = async (chatterId: any) => {
		// Update server-side timestamp
		await updateUserData(chatterId, new Date(), new Date());

		// Update localStorage timestamp to mark chat as read
		const timestampKey = `lastInteraction_${chatterId}`;
		localStorage.setItem(timestampKey, new Date().toISOString());

		if (selectedPage === 'direct') {
			let message = previewDirect.find((message) => message.channel_id === chatterId);
			if (message) {
				message.timestamp = new Date().toString();
				message.notified = false;
				previewDirect = [...previewDirect];
			}
			selectedChat = chatterId;
			selectedChatChannelId = chatterId;
			chatPartner.set(chatterId);
		} else if (selectedPage === 'group') {
			let message = previewGroup.find((message) => message.channel_id === chatterId);
			if (message) {
				message.timestamp = new Date().toString();
				message.notified = false;
				previewGroup = [...previewGroup];
			}
			selectedChat = chatterId;
			chatPartner.set(chatterId);
			selectedChatChannelId = chatterId;
		}
	};

	// Sort chats by notification status
	const sort = (chatter: Group[] | any[], preview: PreviewMessage[]) => {
		return chatter.sort((a, b) => {
			let notifiedMsgA = preview.find((notified) => notified.channel_id === (a.chat_id || a.channel_id));
			let notifiedMsgB = preview.find((notified) => notified.channel_id === (b.chat_id || b.channel_id));
			let notifiedA = notifiedMsgA?.notified || false;
			let notifiedB = notifiedMsgB?.notified || false;
			if (notifiedA === notifiedB) return 0;
			return notifiedA ? -1 : 1;
		});
	};

	// Fetch chat invites
	const UserChatInviteList = async () => {
		const { res, json } = await fetchRequest('GET', `user/chat/invite/list`);
		if (!res.ok) return;
		inviteList = json.results;
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

	// Fetch work groups
	const getWorkGroups = async () => {
		const { res, json } = await fetchRequest('GET', 'group/1/list');
		if (!res.ok) return;
		workGroupList = json.results;
	};

	onMount(async () => {
		if (env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE') getWorkGroups();
		const { json, res } = await fetchRequest('GET', 'user');
		user = json;
		await UserChatInviteList();
		await getChattable();
		// Initialize preview messages with notification status
		await setUpPreview();

		workGroupsStore.subscribe((_workGroups) => {
			workGroupList = _workGroups;
			selectedChat = null;
		});

		chatPartner.subscribe((partner) => {
			if (partner === null) return;
			selectedPage = 'direct';
			selectedChat = partner;
			selectedChatChannelId = partner;
			clickedChatter(partner);
		});
	});

	// Update chat title
	const updateChatTitle = async () => {
		if (selectedChatChannelId) {
			await fetchRequest('POST', 'user/chat/update', {
				channel_id: selectedChatChannelId,
				title: 'chat example'
			});
		}
	};

	$: groups = sort(groups, previewGroup);
	$: directs = sort(directs, previewDirect);
	$: if (selectedChatChannelId) updateChatTitle();
</script>

<div class="col-start-1 col-end-2 row-start-1 row-end-2 dark:bg-darkobject">
	<div class="flex gap-2 relative">
		<Tab
			Class=""
			bind:selectedPage
			tabs={['direct', 'group']}
			displayNames={['Direct', 'Groups']}
		/>
		{#if hasUnreadDirect}
			<span class="absolute top-0 left-0 p-1 rounded-full bg-purple-300" style="left: 50px;"></span>
		{/if}
		{#if hasUnreadGroup}
			<span class="absolute top-0 left-0 p-1 rounded-full bg-blue-300" style="left: 120px;"></span>
		{/if}
	</div>
</div>

<div class="max-h-[100%] overflow-y-auto">
	<div class="border-b-2 w-full">
		<TextInput
			placeholder={selectedPage === 'direct' ? 'Search users' : 'Search groups'}
			label=""
			max={null}
			bind:value={chatSearch}
			inputClass="mt-4 mb-2 placeholder-gray-600 py-1 pl-2 text-gray-500 border-0 bg-gray-100 dark:bg-darkobject"
		/>
	</div>

	{#if selectedPage === 'direct' && inviteList}
		{#each inviteList as groupChat}
			{#if !groupChat.rejected && groupChat?.title?.split(',')?.length > 2}
				{#if groupChat.rejected === null}
					<span>{$_("You've been invited to this chat:")}</span>
					<Button onClick={() => UserChatInvite(true, groupChat.id)}>{$_('Accept')}</Button>
					<Button onClick={() => UserChatInvite(false, groupChat.id)}>{$_('Deny')}</Button>
				{/if}
				<button
					class="w-full transition transition-color p-3 flex items-center gap-3 cursor-pointer dark:bg-darkobject"
					class:bg-gray-200={selectedChat === groupChat.message_channel_id}
					class:dark:bg-gray-700={selectedChat === groupChat.message_channel_id}
					class:dark:hover:bg-darkbackground={groupChat.rejected === false}
					class:hover:bg-gray-200={groupChat.rejected === false}
					class:active:bg-gray-500={groupChat.rejected === false}
					on:click={() => {
						if (groupChat.rejected === false) clickedChatter(groupChat.message_channel_id);
					}}
					disabled={groupChat.rejected === null}
				>
					<ProfilePicture username={groupChat.message_channel_name} profilePicture={null} />
					<div class="flex flex-col max-w-[40%]">
						<span class="max-w-full text-left overflow-x-hidden overflow-ellipsis">
							{groupChat.message_channel_name}
						</span>
						<span class="text-gray-400 text-sm truncate h-[20px] overflow-x-hidden max-w-[10%]" />
					</div>
				</button>
			{/if}
		{/each}
	{/if}

	{#each previewDirect as previewObject}
		{#if selectedPage === 'direct' && previewObject?.channel_title?.split(',')?.length > 2 && previewObject.target_id}
			<button
				class="w-full transition transition-color p-3 flex items-center gap-3 hover:bg-gray-200 active:bg-gray-500 cursor-pointer dark:bg-darkobject dark:hover:bg-darkbackground"
				class:bg-gray-200={selectedChat === previewObject.channel_id}
				class:dark:bg-gray-700={selectedChat === previewObject.channel_id}
				on:click={() => clickedChatter(previewObject.channel_id)}
			>
				{#if previewObject.notified}
					<div class="p-1 rounded-full bg-purple-300" />
				{/if}
				<ProfilePicture
					username={previewObject.channel_title}
					profilePicture={previewObject.profile_image}
				/>
				<div class="flex flex-col max-w-[40%]">
					<span class="max-w-full text-left overflow-x-hidden overflow-ellipsis">
						{previewObject.channel_title}
					</span>
					<span class="text-gray-400 text-sm truncate h-[20px] overflow-x-hidden max-w-[10%]">
						{#if previewObject}
							{previewObject.user.username}: {previewObject.message}
						{/if}
					</span>
				</div>
			</button>
		{/if}
	{/each}

	{#each selectedPage === 'direct' ? directs : env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' ? workGroupList : groups as chatter (chatter.id)}
		{#if (selectedPage === 'group' && env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' && chatter.joined) || env.PUBLIC_ONE_GROUP_FLOWBACK !== 'TRUE' || selectedPage === 'direct'}
			{@const previewObject =
				selectedPage === 'direct'
					? previewDirect.find((direct) => direct.channel_id === chatter.channel_id)
					: previewGroup.find((group) => group.channel_id === chatter.chat_id)}
			<button
				class:hidden={selectedPage === 'direct'
					? !chatter.username.toLowerCase().includes(chatSearch.toLowerCase())
					: !chatter.name.toLowerCase().includes(chatSearch.toLowerCase())}
				class="w-full transition transition-color p-3 flex items-center gap-3 hover:bg-gray-200 active:bg-gray-500 cursor-pointer dark:bg-darkobject dark:hover:bg-darkbackground"
				class:bg-gray-200={selectedChat === (chatter.channel_id || chatter.chat_id)}
				class:dark:bg-gray-700={selectedChat === (chatter.channel_id || chatter.chat_id)}
				on:click={() => clickedChatter(selectedPage === 'direct' ? chatter.channel_id : chatter.chat_id)}
			>
				{#if previewObject?.notified}
					<div class="p-1 rounded-full" class:bg-blue-300={selectedPage === 'group'} class:bg-purple-300={selectedPage === 'direct'} />
				{/if}
				<ProfilePicture
					username={chatter.name || chatter.username}
					profilePicture={chatter.profile_image}
				/>
				<div class="flex flex-col max-w-[40%]">
					<span class="max-w-full text-left overflow-x-hidden overflow-ellipsis">
						{chatter.name || chatter.username}
					</span>
					<span class="text-gray-400 text-sm truncate h-[20px] overflow-x-hidden max-w-[10%]">
						{#if previewObject && previewObject.user && previewObject.message}
							{previewObject.user.username}: {previewObject.message}
						{:else}
							{' '}
						{/if}
					</span>
				</div>
			</button>
			{#if selectedPage === 'direct' && creatingGroup}
				<div>
					<Button
						onClick={() => {
							if (groupMembers.some((member) => member.id === chatter.id)) {
								return;
							}
							const newMember = {
								id: chatter.id,
								username: chatter.username || chatter.name || 'Unknown',
								profile_image: chatter.profile_image || null
							};
							groupMembers = [...groupMembers, newMember];
						}}
					>
						ADD USER
					</Button>
				</div>
			{/if}
		{/if}
	{/each}

	{#if selectedPage === 'group'}
		<Button
			Class="mt-4"
			onClick={() => {
				creatingGroup = true;
				selectedPage = 'direct';
				groupMembers = []; // Reset groupMembers
			}}
		>
			{$_('+ New Group')}
		</Button>
	{/if}
</div>

<style>
	.group-message-bg {
		background: linear-gradient(90deg, rgba(255, 255, 255, 1) 32%, rgba(180, 210, 255, 1) 76%);
	}

	.direct-message-bg {
		background: linear-gradient(90deg, rgb(240, 224, 255) 32%, rgb(255, 255, 255) 76%);
	}

	.both-message-bg {
		background: linear-gradient(90deg, rgb(240, 224, 255) 32%, rgba(180, 210, 255, 1) 76%);
	}
</style>
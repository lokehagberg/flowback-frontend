<script lang="ts">
	import { type invite, type PreviewMessage } from './interfaces';
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
	import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';
	import { PUBLIC_ONE_GROUP_FLOWBACK } from '$env/static/public';
	import { env } from '$env/dynamic/public';

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
		inviteList: invite[] = [];

	onMount(async () => {
		//TODO: Get this from the userinfo sveltestore
		const { json, res } = await fetchRequest('GET', 'user');
		user = json;
		await UserChatInviteList();
		await getChattable();
		await setUpPreview();
		await getWorkGroups();
	});

	const setUpPreview = async () => {
		previewDirect = await getPreview('user');
		previewGroup = await getPreview('group');
	};

	const getPreview = async (selectedPage: 'user' | 'group') => {
		const { res, json } = await fetchRequest(
			'GET',
			`chat/message/channel/preview/list?origin_name=${selectedPage}`
		);

		if (!res.ok) return [];
		return json.results;
	};

	const getChannelId = async (id: number) => {
		const { res, json } = await fetchRequest('GET', `user/chat?target_user_ids=${id}`);
		return json.id;
	};

	const getChattable = async () => {
		if (directs.length + groups.length !== 0) return;

		directs = await userList();
		groups = await groupList();
	};

	const groupList = async () => {
		const { res, json } = await fetchRequest('GET', `group/list?joined=true&limit=${chatLimit}`);
		if (!res.ok) return [];
		return json.results;
	};

	const userList = async () => {
		const { json, res } = await fetchRequest('GET', `users?limit=${chatLimit}`);
		if (!res.ok) return [];
		let chatters = json.results.filter((chatter: any) => chatter.id !== user.id);
		chatters.map(async (chatter: any) => {
			chatter.channel_id = await getChannelId(chatter.id);
			return chatter;
		});
		return chatters;
	};

	const clickedChatter = async (chatter: any) => {
		//Update when user last saw message after clicking on channel

		if (selectedPage === 'direct') {
			// if (selectedChat) updateUserData(await getChannelId(selectedChat), null, new Date());
			let message = previewDirect.find((message) => message.channel_id === chatter.channel_id);

			if (message) {
				//Gets rid of existing notification when clicked on new chat
				message.timestamp = new Date().toString();
				message.notified = false;

				previewDirect = previewDirect;
			}
			selectedChat = chatter.channel_id;
			chatPartner.set(chatter.channel_id);
			selectedChatChannelId = chatter.channel_id;
		} else if (selectedPage === 'group') {
			let message = previewGroup.find((message) => message.channel_id === chatter.chat_id);
			if (message) {
				//Gets rid of existing notification when clicked on new chat
				message.timestamp = new Date().toString();
				message.notified = false;

				previewGroup = previewGroup;
			}

			const id = PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' ? chatter.chat_id : chatter.id;

			selectedChat = id;
			chatPartner.set(id);
			selectedChatChannelId = id;
		}
	};

	//Puts chats with notification circle at the top
	//Puts chats with message between
	//Puts empty chats at the bottom
	//Siamand is doing this, to be changed drastically
	const sort = (chatter: Group[] | any[], preview: PreviewMessage[]) => {
		chatter.sort((a, b) => {
			let notifiedMsgA = preview.find((notified) => notified.channel_id === a.chat_id);
			let notifiedMsgB = preview.find((notified) => notified.channel_id === b.chat_id);

			// Handle cases where notifiedMsg might be undefined
			let notifiedA = notifiedMsgA?.notified || false;
			let notifiedB = notifiedMsgB?.notified || false;

			if (notifiedA === notifiedB) return 0; // If both are the same, they are considered equal
			return notifiedA ? -1 : 1; // If notifiedA is true, it should come before notifiedBF
		});
		return chatter;
	};

	const UserChatInviteList = async () => {
		const { res, json } = await fetchRequest('GET', `user/chat/invite/list`);
		if (!res.ok) return;

		inviteList = json.results;
	};

	const UserChatInvite = async (accept: boolean, invite_id: number) => {
		const { res, json } = await fetchRequest('POST', `user/chat/invite`, {
			invite_id,
			accept
		});
		if (!res.ok) return;
	};

	// Only for one-group flowback
	const getWorkGroups = async () => {
		const { res, json } = await fetchRequest('GET', 'group/1/list');

		if (!res.ok) return;

		workGroupList = json.results;
	};

	$: groups = sort(groups, previewGroup);
</script>

<div class={`col-start-1 col-end-2 row-start-1 row-end-2 dark:bg-darkobject`}>
	<Tab
		Class={``}
		bind:selectedPage
		tabs={['direct', 'group']}
		displayNames={['Direct', 'Groups']}
	/>
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

	{#each inviteList as invitee}
		{#if invitee.rejected === null}
			<div>
				<span>{$_("You've been invite to this chat:")}</span>
				<div>{invitee.message_channel_name}</div>
				<Button onClick={() => UserChatInvite(true, invitee.id)}>{$_('Accept')}</Button>
				<Button onClick={() => UserChatInvite(false, invitee.id)}>{$_('Deny')}</Button>
			</div>
		{/if}
	{/each}

	{#each selectedPage === 'direct' ? directs : env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE' ? workGroupList : groups as chatter}
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
				class:bg-gray-200={selectedChat === chatter.id}
				class:dark:bg-gray-700={selectedChat === chatter.id}
				on:click={() => {
					clickedChatter(chatter);
				}}
			>
				<!-- Notification Symbol -->
				{#if previewObject?.notified}
					<div
						class="p-1 rounded-full"
						class:bg-blue-300={selectedPage === 'group'}
						class:bg-purple-300={selectedPage === 'direct'}
					/>
				{/if}
				<ProfilePicture
					username={chatter.name || chatter.username}
					profilePicture={chatter.profile_image}
				/>
				<div class="flex flex-col max-w-[40%]">
					<span class="max-w-full text-left overflow-x-hidden overflow-ellipsis"
						>{chatter.name || chatter.username}</span
					>
					<span class="text-gray-400 text-sm truncate h-[20px] overflow-x-hidden max-w-[10%]">
						<!-- {@debug previewObject} -->

						{#if previewObject}
							{previewObject.user.username}:
							{previewObject.message}
						{/if}
					</span>
				</div>
			</button>
		{/if}
	{/each}

	{#if selectedPage === "group"}
	<Button onClick={() => creatingGroup = true}>{$_("+ New Group")}</Button>
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

<script lang="ts">
	import { setTimeStamp, type Message, type PreviewMessage } from './interfaces';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Group } from '$lib/Group/interface';
	import Tab from '$lib/Generic/Tab.svelte';
	import type { User } from '$lib/User/interfaces';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { onMount } from 'svelte';

	let groups: Group[] = [],
		directs: any[] = [],
		user: User,
		notifiedDirect: number[] = [],
		notifiedGroup: number[] = [];

	export let selectedChat: number | null,
		// user: User,
		selectedPage: 'direct' | 'group' = 'direct',
		previewDirect: PreviewMessage[] = [],
		previewGroup: PreviewMessage[] = [];

	// $: user &&
	// 	(() => {
	// 		setUpPreview();
	// 		getChattable();
	// 	})();

	onMount(async () => {
		const { json, res } = await fetchRequest('GET', 'user');
		user = json;
		await getChattable();
		await setUpPreview();
		// sortPreview();
	});

	const setUpPreview = async () => {
		previewDirect = await getPreview('direct');
		previewGroup = await getPreview('group');

		notifiedDirect = findNotifications(previewDirect);
		notifiedGroup = findNotifications(previewGroup);
	};

	const getPreview = async (selectedPage: 'direct' | 'group') => {
		const { res, json } = await fetchRequest(
			'GET',
			`chat/${selectedPage}/preview?order_by=created_at_desc`
		);

		if (!res.ok) return;

		return json.results;
	};

	const findNotifications = (preview: any[]) => {
		return preview
			.filter((message: any) => message.timestamp < message.created_at)
			.map((message: any) =>
				message.group_id
					? message.group_id
					: message.target_id === user.id
					? message.user_id
					: message.target_id
			);
	};

	const getChattable = async () => {
		if (directs.length + groups.length !== 0) return;

		directs = await getPeople();
		groups = await getGroups();
	};

	const getGroups = async () => {
		const { res, json } = await fetchRequest('GET', `group/list?joined=true&limit=100`);
		return json.results;
	};

	const getPeople = async () => {
		const { json, res } = await fetchRequest('GET', `users?limit=100`);
		return json.results.filter((chatter: any) => chatter.id !== user.id);
	};

	const clickedChatter = (chatter: any) => {
		//Gets rid of existing notification when clicked on new chat
		if (selectedPage === 'direct') {
			//TODO-user more advanced typescript features to make sure I don't have to use ts-ignore here
			//@ts-ignore
			let message = previewDirect.find(
				(message) => message.target_id === selectedChat || message.user_id === selectedChat
			);
			if (message) message.timestamp = new Date().toString();
			previewDirect = previewDirect;
		} else if (selectedPage === 'group') {
			let message = previewGroup.find((message) => message.group_id === selectedChat);
			if (message) message.timestamp = new Date().toString();
			previewGroup = previewGroup;
		}

		//Switches chat shown to the right of the screen to chatter
		if (selectedChat !== chatter.id) selectedChat = chatter.id;

		setTimeStamp(chatter.id, selectedPage);
	};

	//Puts chats with notification circle at the top
	//Puts chats with message between
	//Puts empty chats at the bottom
	const sort = (chatter: any[], preview: PreviewMessage[], notified: number[]) => {
		chatter.sort((direct) => {
			let notifiedMsg = notified.find((notified) => notified === direct.id);

			if (notifiedMsg) return -1;

			let previewMsg = preview.find(
				(preview) =>
					(preview.target_id === direct.id && preview.user_id === user.id) ||
					(preview.target_id === user.id && preview.user_id === direct.id)
			);

			console.log(previewMsg, direct.id, 'PRVTWIER');
			if (previewMsg) return 0;

			return 1;
		});

		return chatter;
	};

	const sortPreview = () => {
		sort(directs, previewDirect, notifiedDirect);
		directs = directs;

		sort(groups, previewGroup, notifiedGroup);
		groups = groups;
	};

	//Adds notification data to chats where a new message just dropped
	$: {
		//TODO: Use advanced typescript features to not have the ignore
		if (user) {
			let newMember = directs.find((direct) => !previewDirect.find(previewMsg => previewMsg.user_id === direct.id));
			if (newMember)
				directs.push({
					id: newMember.id,
					profile_image: newMember.profile_image,
					username: newMember.username
				});

			//@ts-ignore
			notifiedDirect = previewDirect
				.filter(
					(message) =>
						message.timestamp <= message.created_at &&
						message.target_id !== selectedChat &&
						message.user_id !== selectedChat
				)
				.map((message) => (message.target_id === user.id ? message.user_id : message.target_id));

			console.log(notifiedDirect, 'NOTIS');
		}
	}

	$: {
		if (user) {
			//@ts-ignore
			notifiedGroup = previewGroup
				.filter(
					(message) => message.timestamp < message.created_at && message.group_id !== selectedChat
				)
				.map((message) => message.group_id);

			console.log(notifiedGroup);
		}
	}
</script>

<div
	class={`col-start-1 col-end-2 row-start-1 row-end-2 ${
		notifiedDirect.length && notifiedGroup.length
			? 'both-message-bg'
			: notifiedDirect.length > 0
			? 'direct-message-bg'
			: notifiedGroup.length > 0
			? 'group-message-bg'
			: 'bg-white'
	}`}
>
	<Tab
		Class={``}
		bind:selectedPage
		tabs={['direct', 'group']}
		displayNames={['Direct', 'Groups']}
	/>
</div>

<ul
	class="row-start-2 row-end-4 bg-white flex flex-col sm:h-[30-vh] md:h-[80vh] lg:h-[90vh] overflow-y-scroll"
>
	{#each selectedPage === 'direct' ? directs : groups as chatter}
		<li
			class="transition transition-color p-3 flex items-center gap-3 hover:bg-gray-200 active:bg-gray-500 cursor-pointer"
			class:bg-gray-200={selectedChat === chatter.id}
			on:click={async () => {
				//TODO: Better fix than this! Fixes doubble clicking to remove notification
				await setTimeout(() => {
					clickedChatter(chatter);
				}, 100);
				clickedChatter(chatter);
			}}
		>
			{#if (selectedPage === 'direct' ? notifiedDirect : notifiedGroup).includes(chatter.id)}
				<div
					class="p-1 rounded-full"
					class:bg-purple-400={selectedPage === 'direct'}
					class:bg-blue-300={selectedPage === 'group'}
				/>
			{/if}
			<ProfilePicture user={chatter} />
			<div class="flex flex-col">
				<span>{chatter.name || chatter.username}</span>
				<span class="text-gray-400 text-sm truncate h-[20px]">
					{(selectedPage === 'direct' ? previewDirect : previewGroup).find(
						(message) =>
							(user.id !== message.target_id &&
								message.target_id === chatter.id &&
								selectedPage === 'direct') ||
							(user.id !== message.user_id &&
								message.user_id === chatter.id &&
								selectedPage === 'direct') ||
							(message.group_id === chatter.id && selectedPage === 'group')
					)?.message || ''}
				</span>
			</div>
		</li>
	{/each}
</ul>

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

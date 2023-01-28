<script lang="ts">
	import { onDestroy, onMount } from 'svelte';
	// @ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { Message } from './interfaces';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faComment } from '@fortawesome/free-solid-svg-icons/faComment';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Group } from '$lib/Group/interface';
	import Tab from '$lib/Generic/Tab.svelte';
	import type { Unsubscriber } from 'svelte/store';
	import type { User } from '$lib/User/interfaces';
	import { formatDate } from '$lib/Generic/DateFormatter';
	import { number, _ } from 'svelte-i18n';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';

	//TODO: Refactor the chat, both code-wise and design-wise

	// User Action variables
	let // Specifies which chat window is open
		groups: Group[] = [],
		directs: any[] = [],
		selectedPage: 'direct' | 'group' = 'direct',
		previewDirect: any[] = [],
		previewGroup: any[] = [],
		notifiedDirect: number[] = [],
		notifiedGroup: number[] = [];

	export let selectedChat: number, user: User;

	$: user &&
		(() => {
			setUpPreview();
			getChattable();
		})();

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
			notifiedDirect = notifiedDirect.filter((notis) => notis !== chatter.id);
			notifiedDirect = notifiedDirect;
		} else if (selectedPage === 'group') {
			notifiedGroup = notifiedGroup.filter((notis) => notis !== chatter.id);
			notifiedGroup = notifiedGroup;
		}

		//Switches chat shown to the right of the screen to chatter
		if (selectedChat !== chatter.id) selectedChat = chatter.id;

		setTimeStamp(chatter.id);
	};

	//User has looked at a message, affects /preview primarily.
	const setTimeStamp = async (chatterId: number) => {
		fetchRequest('POST', `chat/${selectedPage}/${chatterId}/timestamp`, {
			timestamp: new Date()
		});
	};
</script>

<div class="col-start-1 col-end-2 row-start-1 row-end-2">
	<Tab bind:selectedPage tabs={['direct', 'group']} displayNames={['Direct', 'Groups']} />
</div>

<ul
	class="row-start-2 row-end-4 bg-white flex flex-col sm:h-[30-vh] md:h-[80vh] lg:h-[90vh] overflow-y-scroll"
>
	{#each selectedPage === 'direct' ? directs : groups as chatter}
		<li
			class="transition transition-color p-3 flex items-center gap-3 hover:bg-gray-200 active:bg-gray-500 cursor-pointer"
			class:bg-gray-200={selectedChat === chatter.id}
			on:click={() => clickedChatter(chatter)}
		>
			{#if (selectedPage === 'direct' ? notifiedDirect : notifiedGroup).includes(chatter.id)}
				<div class="bg-purple-400 p-1 rounded-full" />
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
	.grid-width-fix {
		grid-template-columns: 30% 70%;
		grid-template-rows: 3rem 50vh 50vh;
	}

	.small-notification:before {
		position: absolute;
		content: '';
		top: 0;
		right: 0;
		background-color: rgb(167, 139, 250);
		border-radius: 100%;
		padding: 10px;
		z-index: 10;
	}

	.small-notification-group:after {
		position: absolute;
		content: '';
		top: 10px;
		right: 0;
		background-color: rgb(147, 197, 235);
		border-radius: 100%;
		padding: 10px;
	}
</style>

<script lang="ts">
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faBell } from '@fortawesome/free-solid-svg-icons/faBell';
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { notification } from './Notification';
	import TimeAgo from 'javascript-time-ago';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { goto } from '$app/navigation';

	let notifications: notification[],
		hovered: number[] = [];

	const getNotifications = async () => {
		//Prevents infinite reload in /login where <Header /> is hidden
		if (location.pathname === '/login') return;
		const { json, res } = await fetchRequest('GET', 'notification/list');
		if (res.ok) notifications = json.results;
	};

	const closeWindowWhenClickingOutside = () => {
		window.addEventListener('click', function (e) {
			const notificationListElement = document.getElementById(`notifications-list`);
			if (
				notificationsOpen &&
				//@ts-ignore
				!notificationListElement?.contains(e.target)
			) {
				notificationsOpen = false;
			}
		});
	};

	const readNotification = async (id: number) => {
		const { res, json } = await fetchRequest('POST', 'notification/read', {
			notification_ids: [id],
			read: true
		});
		if (!res.ok) return;

		notifications = notifications.filter((notification) => notification.id !== id);
	};

	const markAllAsRead = async () => {
		const { res, json } = await fetchRequest('POST', 'notification/read', {
			notification_ids: notifications.map((notification) => notification.id),
			read: true
		});
		if (!res.ok) return;

		notifications = [];
	};

	let timeAgo: TimeAgo;
	onMount(async () => {
		const en = (await import('javascript-time-ago/locale/en')).default;
		TimeAgo.addDefaultLocale(en);
		timeAgo = new TimeAgo('en');

		getNotifications();
		closeWindowWhenClickingOutside();
	});

	let notificationsOpen = false;
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	id="notifications-list"
	class="small-notification relative cursor-pointer"
	on:click={() => (notificationsOpen = !notificationsOpen)}
	on:keydown
>
	<Fa icon={faBell} size={'1.4x'} />
	<div
		class:hidden={notifications?.length === 0 || notifications?.length === undefined}
		class="w-[2em] h-[2em] flex items-center justify-center rounded-full absolute -top-1.5 -right-1.5 text-[10px] text-white bg-secondary"
	>
		<span class="">{notifications?.length}</span>
	</div>
</div>

{#if notificationsOpen}
	<ul
		class="absolute right-0 top-full bg-white dark:bg-darkobject dark:text-darkmodeText select-none shadow slide-animation z-[60]"
		id="notifications-list"
	>
		<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
		<li
			on:click={markAllAsRead}
			on:keydown
			class="flex justify-end items-center cursor-pointer border-b border-gray-200 border hover:shadow hover:bg-blue-300 transition-all"
		>
			{$_('Mark all as read')}
		</li>
		{#if notifications?.length > 0}
			{#each notifications as notification}
				<!-- svelte-ignore a11y-no-static-element-interactions -->
				<li
					class="flex justify-end items-center cursor-pointer border-b border-gray-200 border hover:shadow hover:bg-blue-300 transition-all"
					class:bg-gray-200={hovered.find((hover) => hover === notification.id)}
				>
					<!-- svelte-ignore a11y-no-static-element-interactions -->
					<div
						class="pt-3 pb-3 pr-10 pl-6"
						on:click={async () => {
							if (notification.channel_sender_type === 'group')
								goto(`groups/${notification.channel_id}?page=${notification.channel_category}`);
							else if (notification.channel_sender_type === 'poll') {
								const { res, json } = await fetchRequest(
									'GET',
									`home/polls?id=${notification.channel_sender_id}`
								);
								const groupId = json.results[0].group_id;
								goto(`/groups/${groupId}/polls/${notification.channel_sender_id}`);
							}
						}}
						on:keydown
					>
						<div class=" max-w-[25vw] overflow-x-hidden overflow-ellipsis whitespace-nowrap">
							{$_(notification.message)}
							{timeAgo.format(new Date(notification.timestamp))}
						</div>
					</div>
					<div
						style="z-index: 1;"
						class="mr-8"
						on:click={() => {
							readNotification(notification.id);
							setTimeout(() => {
								notificationsOpen = true;
							}, 100);
							// hovered.push(notification.id);
							// hovered = hovered;
						}}
						on:keydown
					>
						<Fa icon={faX} />
					</div>
				</li>
			{/each}
		{:else}
			<div class="pt-3 pb-3 pr-10 pl-6 border-b border-gray-200 border cursor-default">
				{$_('No notifications')}
			</div>
		{/if}
	</ul>
{/if}

<style>
	@keyframes slide-animation {
		from {
			top: 80%;
		}
		to {
			top: 100%;
		}
	}

	.slide-animation {
		animation-name: slide-animation;
		animation-duration: 300ms;
	}
</style>

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
	import { notifications as notificationLimit } from '$lib/Generic/APILimits.json';
	import { darkModeStore } from '$lib/Generic/DarkMode';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import { N } from 'ethers';

	let notifications: notification[],
		timeAgo: TimeAgo,
		notificationsOpen = false;

	const notificationList = async () => {
		//Prevents infinite reload in /login where <Header /> is hidden
		if (location.pathname === '/login') return;
		const { json, res } = await fetchRequest(
			'GET',
			`notification/list?order_by=timestamp_desc&limit=${notificationLimit}`
		);
		if (res.ok) notifications = json?.results;
	};

	const closeWindowWhenClickingOutside = () => {
		window.addEventListener('click', (e) => {
			const notificationListElement =
				document.getElementById(`notifications-list`);
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
		const { res, json } = await fetchRequest('POST', 'notification/update', {
			notification_object_ids: [id],
			read: true
		});
		if (!res.ok) return;

		// notifications = notifications.filter((notification) => notification.id !== id);
		// let notification = notifications.find(n => n.object_id === id)
		// notification?.read = true;
	};

	const markAllAsRead = async () => {
		const { res, json } = await fetchRequest('POST', 'notification/update', {
			notification_object_ids: notifications.map(
				(notification) => notification.object_id
			),
			read: true
		});

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: "Couldn't mark all notifications as read",
				success: false
			});
			return;
		}

		notifications = notifications.map((n) => ({ ...n, read: (n.read = true) }));
	};

	const gotoNotificationOrigin = async (notification: notification) => {
		switch (notification.tag) {
			case 'poll':
			case 'poll_vote_update':
				await goto(
					`/groups/${notification.data.group_id}/polls/${notification.data.poll_id}?source=notification`
				);
				return;
			case 'poll_comment':
				await goto(
					`/groups/${notification.data.group_id}/thread/${notification.data.thread_id}?section=comments&source=notification`
				);
				return;
			case 'thread':
				await goto(
					`/groups/${notification.data.group_id}/thread/${notification.data.thread_id}?source=notification`
				);
				return;
			case 'thread_comment':
				// TODO: Fix scuffed solution with channel_data by changing data in backend probably group models.py
				await goto(
					`/groups/${notification.data.group_id}/thread/${notification.channel_data.thread_id}?section=comments&source=notification`
				);
				return;
			case 'group_user':
				await goto(`/groups/${notification.data.group_id}?page=members`);
				return;
			case 'kanban':
				await goto(`/kanban?groupId=${notification.data.group_id}`);
				return;
			case 'schedule':
				await goto(`/schedule?groupId=${notification.data.group_id}`);
				return;
			default:
				return;
		}
	};

	onMount(async () => {
		const en = (await import('javascript-time-ago/locale/en')).default;
		TimeAgo.addDefaultLocale(en);
		timeAgo = new TimeAgo('en');

		notificationList();
		closeWindowWhenClickingOutside();
	});
</script>

<!-- Notification bell in the header -->
<button
	id="notifications-list"
	class="small-notification relative cursor-pointer"
	on:click={() => (notificationsOpen = !notificationsOpen)}
>
	<Fa icon={faBell} color={$darkModeStore ? 'white' : 'black'} size={'1.3x'} />
	<div
		class:hidden={!notifications ||
			notifications?.filter((n) => !n.read)?.length === 0}
		class="w-[2em] h-[2em] flex items-center justify-center rounded-full absolute -top-1.5 -right-1.5 text-[10px] text-white bg-secondary"
	>
		<span>{Math.min(99, notifications?.filter((n) => !n.read)?.length)}</span>
	</div>
</button>

<!-- Menu of notifications, that for now opens when clicking the notification bell in the header -->
{#if notificationsOpen}
	<ul
		class="max-h-[90vh] overflow-y-scroll absolute right-0 top-full bg-white dark:bg-darkobject dark:text-darkmodeText select-none shadow slide-animation z-[60]"
		id="notifications-list"
	>
		<button
			on:click={markAllAsRead}
			class="w-full flex justify-end items-center cursor-pointer border-b border-gray-200 dark:border-gray-600 border hover:shadow hover:bg-blue-100 hover:border-l-2 hover:border-l-primary transition-all"
		>
			<span class="mr-4">{$_('Mark all as read')}</span>
		</button>
		{#if notifications?.length > 0}
			{#each notifications as notification}
				<li
					class=" flex justify-between max-w-[25rem] border-gray-200 dark:border-gray-600 border hover:shadow transition-all dark:hover:bg-slate-700 hover:bg-blue-300 hover:border-l-2 hover:border-l-primary"
					class:bg-green-300={!notification.read}
					class:dark:bg-slate-600={!notification.read}
				>
					<button
						on:click={async () => {
							await gotoNotificationOrigin(notification);
							await readNotification(notification.object_id);
							notification.read = true;
						}}
					>
						<div class="break-words pr-8 text-left pl-4 py-2">
							<div>{$_(notification.message)}</div>
							<div class="text-sm">
								{timeAgo.format(new Date(notification.timestamp))}
							</div>
						</div>
					</button>
					<button
						style="z-index: 1;"
						class="pr-4"
						on:click={async () => {
							await readNotification(notification.object_id);
							notification.read = true;

							// setTimeout(() => {
							// 	notificationsOpen = true;
							// }, 100);
							// hovered.push(notification.id);
							// hovered = hovered;
						}}
					>
						<!-- <Fa icon={faX} class="text-gray-300" /> -->
					</button>
				</li>
			{/each}
		{:else}
			<div
				class="pt-3 pb-3 pr-10 pl-6 border-b border-gray-200 border cursor-default"
			>
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

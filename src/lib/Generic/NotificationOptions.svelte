<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { faBell } from '@fortawesome/free-solid-svg-icons/faBell';
	import { faBellSlash } from '@fortawesome/free-solid-svg-icons/faBellSlash';
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { darkModeStore } from '$lib/Generic/DarkMode';
	import { ErrorHandlerStore } from './ErrorHandlerStore';

	let {
		notificationOpen = false,
		categories,
		labels,
		type,
		api,
		id,
		Class = '',
		ClassOpen = '',
		hoverEffect = true
	}: {
		notificationOpen?: boolean;
		categories: string[];
		labels: string[];
		type: 'poll' | 'group' | 'thread' | 'delegation' | 'event';
		api: string;
		id: number;
		Class?: string;
		ClassOpen?: string;
		hoverEffect?: boolean;
	} = $props();

	let notifications: NotificationObject[] = $state([]);

	interface NotificationObject {
		channel_category: string;
		channel_sender_id: number;
		channel_sender_type: string;
	}

	interface NotificationSubscriptionResponse {
		origin_id: number;
		channel_id: number;
		channel_name: 'group' | 'poll' | 'thread';
		tags: {
			name: string;
			reminders: null;
		}[];
	}

	const closeWindowWhenClickingOutside = () => {
		window.addEventListener('click', function (e) {
			if (
				notificationOpen &&
				//@ts-ignore
				![
					...document.getElementsByClassName(`notifications-clickable-region`)
				]?.find((element) =>
					//@ts-ignore
					element.contains(e.target)
				)
			) {
				notificationOpen = false;
			}
		});
	};

	const getNotifications = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			'notification/subscription'
		);
		if (!res.ok) return;

		const notificationsData = json.results.find(
			(notification: NotificationSubscriptionResponse) =>
				notification.origin_id === id
		);

		notifications = notificationsData
			? notificationsData.tags.map((tag: any) => ({
					channel_category: tag.name,
					channel_sender_id: id,
					channel_sender_type: type
				}))
			: [];
	};

	const notificationSubscription = async (
		category: string,
		method: 'add' | 'remove' = 'add'
	) => {
		method === 'add'
			? (notifications = [
					...notifications,
					{
						channel_category: category,
						channel_sender_id: id,
						channel_sender_type: type
					}
				])
			: (notifications = notifications.filter(
					(item) => item.channel_category !== category
				));

		let payload: any = {
			tags: notifications.map((notification) => notification.channel_category)
		};
		if (type === 'event') payload['event_ids'] = id.toString();

		const { res, json } = await fetchRequest('POST', `${api}`, payload);
		if (!res.ok) {
			ErrorHandlerStore.set({
				message: (() => {
					if (method === 'add') {
						const msg = json.detail[0];
						if (msg === 'Event is not active or has already ended.') return msg;
						else return 'Failed to subscribe';
					} else return 'Failed to unsubscribe';
				})(),
				success: false
			});
			return;
		}

		method === 'add'
			? notifications.push({
					channel_category: category,
					channel_sender_id: id,
					channel_sender_type: type
				})
			: (notifications = notifications.filter(
					(notification) => notification.channel_category !== category
				));

		if (method === 'add')
			ErrorHandlerStore.set({ message: 'Subscribed', success: true });
		else ErrorHandlerStore.set({ message: 'Unsubscribed', success: true });

		notifications = notifications;
	};

	const subscribeToAll = async () => {
		const { res, json } = await fetchRequest('POST', `${api}`, {
			tags: categories
		});

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to subscribe to all',
				success: false
			});
			return;
		}

		ErrorHandlerStore.set({ message: 'Subscribed to all', success: true });

		notifications = categories.map((category) => ({
			channel_category: category,
			channel_sender_id: id,
			channel_sender_type: type
		}));
	};

	onMount(() => {
		closeWindowWhenClickingOutside();
		// getNotifications();
	});

	$effect(() => {
		if (notificationOpen) {
			getNotifications();
		}
	});
</script>

<div class={`${Class} notifications-clickable-region relative z-100 `}>
	<button
		type="button"
		class={``}
		onclick={() => {
			notificationOpen = !notificationOpen;
		}}
	>
		{#key darkModeStore}
			<Fa
				class={'hover:cursor-pointer hover:text-primary dark:text-secondary'}
				icon={faBell}
				size={'1.2x'}
			/>
		{/key}
	</button>

	{#if notificationOpen && categories}
		<div
			class={`z-40 absolute mt-2 bg-white dark:bg-darkobject shadow-xl text-sm ${ClassOpen}`}
		>
			<div class="text-xs p-2">{$_('Manage Subscriptions')}</div>
			{#if type !== 'event'}
				<button
					onclick={(e) => {
						e.preventDefault();
						subscribeToAll();
					}}
					class="text-xs p-2">{$_('Subscribe to All')}</button
				>{/if}
			{#each categories as category, i}
				<button
					class="bg-gray-200 dark:bg-gray-700 w-full p-2 px-5 flex justify-between items-center transition-all"
					class:active:bg-gray-400={hoverEffect}
					class:dark:active:bg-slate-700={hoverEffect}
					class:dark:active:bg-slate-900={hoverEffect}
					class:hover:bg-gray-300={hoverEffect}
					class:hover:cursor-pointer={hoverEffect}
					class:dark:hover:bg-slate-800={hoverEffect}
					class:!bg-white={notifications?.find(
						(notificationObject) =>
							notificationObject.channel_category === category
					)}
					class:dark:!bg-slate-400={notifications?.find(
						(notificationObject) =>
							notificationObject.channel_category === category
					)}
					onclick={(e) => {
						e.preventDefault();
						if (
							!notifications.find(
								(object) => object.channel_category === category
							)
						)
							notificationSubscription(category, 'add');
						else notificationSubscription(category, 'remove');
					}}
				>
					{$_(labels[i])}
					<Fa
						class=""
						color={notifications?.find(
							(notificationObject) =>
								notificationObject.channel_category === category
						)
							? 'black'
							: 'white'}
						swapOpacity
						icon={notifications?.find(
							(notificationObject) =>
								notificationObject.channel_category === category
						)
							? faBell
							: faBellSlash}
						size={'1.4x'}
					/>
				</button>
			{/each}
		</div>
	{/if}
</div>

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { faBell } from '@fortawesome/free-solid-svg-icons/faBell';
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';

	export let notificationOpen = false,
		categories: string[],
		labels: string[],
		api: string,
		id: number;

	interface NotificationObject {
		channel_category: string;
		channel_sender_id: number;
		channel_sender_type: string;
	}

	let categoriesData: string[] = [],
		notifications: NotificationObject[] = [];

	const closeWindowWhenClickingOutside = () => {
		window.addEventListener('click', function (e) {
			if (
				notificationOpen &&
				//@ts-ignore
				![...document.getElementsByClassName(`notifications-clickable-region`)]?.find((element) =>
					element.contains(e.target)
				)
			) {
				notificationOpen = false;
			}
		});
	};

	const getNontifications = async () => {
		const { res, json } = await fetchRequest('GET', 'notification/subscription');
		notifications = json.results.filter(
			(notificationObject: any) => notificationObject.channel_sender_id === id
		);
	};

	const handleNotificationSubscription = async (category: string) => {
		const { res, json } = await fetchRequest('POST', `${api}/subscribe`, {
			categories: [category]
		});
		if (res.ok)
			notifications.push({
				channel_category: category,
				channel_sender_id: id,
				channel_sender_type: 'group'
			});
		notifications = notifications;
	};
	const handleNotificationUnsubscription = async (category: string) => {
		const { res, json } = await fetchRequest('POST', `notification/unsubscribe`, {
			channel_sender_type: 'group',
			channel_sender_id: id,
			channel_category: category
		});
		if (res.ok)
			notifications = notifications.filter((object) => object.channel_category !== category);
	};

	onMount(() => {
		closeWindowWhenClickingOutside();
	});

	$: if (notificationOpen && notifications.length === 0) getNontifications();

	$: console.log(notifications);
</script>

<div class="notifications-clickable-region">
	<div
		on:click={() => {
			notificationOpen = !notificationOpen;
		}}
	>
		<Fa class="hover:cursor-pointer hover:text-primary" icon={faBell} size={'1.4x'} />
	</div>

	{#if notificationOpen}
		<ul class="z-50 absolute mt-2 bg-white shadow-xl text-sm">
			<!-- <div class="p-3">Subscriptions</div> -->
			{#each categories as category, i}
				<li
					class="bg-gray-200 p-2 px-5 flex justify-between items-center hover:cursor-pointer hover:bg-gray-300 active:bg-gray-400 transition-all"
					class:!bg-white={notifications?.find(
						(notificationObject) => notificationObject.channel_category === category
					)}
					on:click={() => {
						if (notifications.find((object) => object.channel_category === category))
							handleNotificationUnsubscription(category);
						else handleNotificationSubscription(category);
					}}
				>
					{$_(labels[i])}
					<Fa class="" color={notifications?.find(
						(notificationObject) => notificationObject.channel_category === category
					) ? "black" : "white"} swapOpacity icon={faBell} size={'1.4x'} />
				</li>
			{/each}
		</ul>
	{/if}
</div>

<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faBell } from '@fortawesome/free-solid-svg-icons/faBell';
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import Button from '$lib/Generic/Button.svelte';

	type NotificationType = 'kanban' | 'group';
	interface Notification {
		action: () => void;
		type: NotificationType;
		title: string;
	}

	const notifications: Notification[] = [
		{ action: () => {}, title: 'Notification example', type: 'kanban' }
	];

	const getNotifications = async () => {
		await fetchRequest('POST', `group/4/subscribe`, { categories: [] });
		const { json, res } = await fetchRequest('GET', 'notification/subscriptions');
	};

	onMount(() => {
		getNotifications();
	});

	let notificationsOpen = false;
</script>

<div on:click={() => (notificationsOpen = !notificationsOpen)}>
	<Fa icon={faBell} size={'1.4x'} />
</div>

{#if notificationsOpen}
	<div class="absolute right-0 top-full bg-white select-none shadow slide-animation">
		{#each notifications as notification}
			<div
				class="cursor-pointer pt-3 pb-3 pr-10 pl-6 border-b border-gray-200 border hover:shadow hover:bg-blue-300 transition-shadow transition-colors"
				on:click={notification.action}
			>
				{$_(notification.title)}
			</div>
		{/each}
	</div>
{/if}

<Button action={async () => {

	const {res, json} = await fetchRequest('GET', 'notification/list')
	 await fetchRequest('GET', 'notification/subscription')
	// const {res, json} = await fetchRequest('POST', 'notification/read')
	// const {res, json} = await fetchRequest('POST', 'group/3/subscribe', {categories: ["group"]})
	// const {res, json} = await fetchRequest('POST', 'group/3/unsubscribe', {categories: ["group"]})



	console.log(res, json, "NOTIS")
}}/>

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

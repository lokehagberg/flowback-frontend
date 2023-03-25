<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faBell } from '@fortawesome/free-solid-svg-icons/faBell';
	import { _ } from 'svelte-i18n';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import Button from '$lib/Generic/Button.svelte';
	import type { notification } from './Notification';

	let notifications:notification[];

	const getNotifications = async () => {
		const { json, res } = await fetchRequest('GET', 'notification/list');
		notifications = json.results
	};

	const closeWindowWhenClickingOutside = () => {
		window.addEventListener('click', function (e) {
			if (
				notificationsOpen &&
				//@ts-ignore
				!document.getElementById(`notifications-list`)?.contains(e.target)
			) {
				notificationsOpen = false;
			}
		});
	}

	onMount(() => {
		getNotifications();
		closeWindowWhenClickingOutside();
	});

	let notificationsOpen = false;
</script>

<div id ="notifications-list" on:click={() => (notificationsOpen = !notificationsOpen)}>
	<Fa icon={faBell} size={'1.4x'} />
</div>

{#if notificationsOpen}
	<div class="absolute right-0 top-full bg-white select-none shadow slide-animation" id ="notifications-list">
		{#each notifications as notification}
		<!-- on:click={notification.action} -->
			<div
				class="cursor-pointer pt-3 pb-3 pr-10 pl-6 border-b border-gray-200 border hover:shadow hover:bg-blue-300 transition-shadow transition-colors"
			>
				{$_(notification.message)}
			</div>
		{/each}
	</div>
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

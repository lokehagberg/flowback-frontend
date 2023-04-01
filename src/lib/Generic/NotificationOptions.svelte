<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { faBell } from '@fortawesome/free-solid-svg-icons/faBell';
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';

	export let notificationOpen = false,
		categories: string[],
		labels: string[],
		api: string;

    let categoriesData:string[] = []

	const closeWindowWhenClickingOutside = () => {
		window.addEventListener('click', function (e) {
			if (
				notificationOpen &&
				//@ts-ignore
				! [... document.getElementsByClassName(`notifications-clickable-region`)]?.find(element => element.contains(e.target) ) 
			) {
				notificationOpen = false;
			}
		});
	};

	const getNontifications = async () => {
		await fetchRequest('GET', 'notification/subscription')
	}

	const handleNotificationSubscription = async (category:string) => {
		// await fetchRequest('POST', `group/${$page.params.groupId}/unsubscribe`);
		await fetchRequest('POST', api, { categories:[category] });
	};

	const getAlreadySubscribedCategories = async () => {

		

		const {res, json} = await fetchRequest("GET", "notification/subscriptions")
		{
			const {res, json} = await fetchRequest("GET", "home/polls")
		}
	}

	onMount(() => {
		closeWindowWhenClickingOutside();
		getNontifications();
	});

</script>

<div class="notifications-clickable-region">
	<div on:click={() => {
		notificationOpen = !notificationOpen
		getAlreadySubscribedCategories();
	}}>
		<Fa class="hover:cursor-pointer hover:text-primary" icon={faBell} size={'1.4x'} />
	</div>

	{#if notificationOpen}
		<ul class="z-50 absolute top-12 bg-white shadow-xl text-sm">
			{#each categories as category, i}
				<li class="p-2 px-5 flex items-center hover:cursor-pointer hover:bg-gray-300 active:bg-gray-400 transition-all" class:bg-gray-200={categoriesData?.find((cat) => cat === category)} on:click={() => handleNotificationSubscription(category)}>
					{$_(labels[i])}
				</li>
			{/each}
		</ul>
	{/if}
</div>

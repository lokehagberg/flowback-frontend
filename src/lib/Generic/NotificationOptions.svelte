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
				!document.getElementById(`notifications-list-group`)?.contains(e.target)
			) {
				notificationOpen = false;
			}
		});
	};

	const handleNotificationSubscription = async () => {
		// await fetchRequest('POST', `group/${$page.params.groupId}/unsubscribe`);
		await fetchRequest('POST', api, { categories:categoriesData });
	};

	const changeNotificationList = (newCategory: string) => {
		const oldCategory = categoriesData?.find((category) => category === newCategory);
		if (oldCategory) categoriesData = categoriesData.filter((category) => category !== newCategory);
		else categoriesData?.push(newCategory);
		categories = categories;
		handleNotificationSubscription();
	};

	onMount(() => {
       
		closeWindowWhenClickingOutside();
	});
</script>

<div>
	<div on:click={() => (notificationOpen = !notificationOpen)}>
		<Fa class="hover:cursor-pointer hover:text-primary" icon={faBell} size={'1.4x'} />
	</div>

	{#if notificationOpen}
		<ul class="z-50 absolute top-12 bg-white shadow text-sm">
			{#each categories as category, i}
				<li class="p-2 flex items-center" on:click={() => changeNotificationList(category)}>
					<input
						class="hover:shadow p-1 hover:bg-gray-100 transition-all"
						type="checkbox"
						id={category}
					/><label for={category} class="ml-2 mb-0.5">{$_(labels[i])}</label>
				</li>
			{/each}
		</ul>
	{/if}
</div>

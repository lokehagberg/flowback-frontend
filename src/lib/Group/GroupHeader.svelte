<script lang="ts">
	import type { GroupDetails, SelectablePage } from './interface';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faBell } from '@fortawesome/free-solid-svg-icons/faBell';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	export let selectedPage: SelectablePage;
	export let group: GroupDetails;
	export let memberCount: number;

	//https://docs.flowback.org/#notification-categories
	const groupNotificationCategories = [
		'group',
		'members',
		'invite',
		'delegate',
		'poll',
		'kanban',
		'schedule'
	];
	
	let notificationOpen = false, categories:string[] = []

	const handleNotificationSubscription = async () => {
		await fetchRequest('POST', `group/${$page.params.groupId}/unsubscribe`);
		await fetchRequest('POST', `group/${$page.params.groupId}/subscribe`, { categories });
	};

	const changeNotificationList = (newCategory:string) => {
		const oldCategory = categories.find(category => category === newCategory)
		if (oldCategory) categories = categories.filter(category => category === newCategory)
		else categories.push(newCategory)
		categories = categories
		handleNotificationSubscription()
	}

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
	}

	onMount(() => {
		closeWindowWhenClickingOutside();
	})
	
</script>

<div class="relative flex justify-center">
	<img class="cover " src={`${import.meta.env.VITE_API}${group.cover_image}`} alt="cover" />
	<img
		class="h-36 w-36 absolute -bottom-8 left-[15%] md:left-[25%] profile rounded-full"
		src={`${import.meta.env.VITE_API}${group.image}`}
		alt="profile"
	/>
</div>
<!-- TODO: Fix layout design -->
<div class="bg-white pt-12 flex justify-evenly align-middle pl-4 pr-4 pb-4">
	<div class="flex items-center relative" id="notifications-list-group">
		<div on:click={() => (notificationOpen = !notificationOpen)}>
			<Fa class="hover:cursor-pointer hover:text-primary" icon={faBell} size={'1.4x'} />
		</div>
		<h1
			class="ml-2 text-3xl hover:underline cursor-pointer"
			on:click={() => (selectedPage = 'flow')}
		>
			{group.name}
		</h1>
		{#if notificationOpen}
			<ul class="z-50 absolute top-12 bg-white shadow text-sm" >
				{#each groupNotificationCategories as category}
					<li class="p-2 flex items-center" on:click={() => changeNotificationList(category)}>
						<input
							class="hover:shadow p-1 hover:bg-gray-100 transition-all"
							type="checkbox"
							id={category}
						/><label for={category} class="ml-2 mb-0.5">{$_(category)}</label>
					</li>
				{/each}
			</ul>
		{/if}
	</div>
	<p class="text-xl hover:underline cursor-pointer" on:click={() => (selectedPage = 'members')}>
		{memberCount}
		{$_('members')}
	</p>
</div>

<style>
	img.cover {
		aspect-ratio: 4;
		/* width: 100%; */
	}

	img.profile {
		width: 100px;
		height: 100px;
	}
</style>

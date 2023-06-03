<script lang="ts">
	import type { GroupDetails, SelectablePage } from './interface';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import { faLock } from '@fortawesome/free-solid-svg-icons/faLock';
	import { faGlobeEurope } from '@fortawesome/free-solid-svg-icons/faGlobeEurope';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import DefaultBanner from '$lib/assets/default_banner_group.png';

	export let selectedPage: SelectablePage, group: GroupDetails, memberCount: number;

	//https://docs.flowback.org/#notification-categories
	const groupNotificationCategories = [
		'group',
		'members',
		'delegate',
		//invite,
		'poll',
		'kanban',
		'schedule'
	];
</script>

<div class="relative flex justify-center">
	<img class="cover " src={`${import.meta.env.VITE_API}${group.cover_image}`} alt="cover" />
	<img
		class="h-36 w-36 absolute -bottom-8 left-[15%] md:left-[25%] profile rounded-full"
		src={group.image ? `${import.meta.env.VITE_API}${group.image}` : DefaultBanner}
		alt="profile"
	/>
</div>
<!-- TODO: Fix layout design -->
<div class="bg-white dark:bg-darkobject dark:text-darkmodeText pt-12 flex justify-evenly align-middle pl-4 pr-4 pb-4">
	<div class="flex items-center relative" id="notifications-list-group">
		<NotificationOptions
			api={`group/${$page.params.groupId}`}
			id = {Number($page.params.groupId)}
			categories={groupNotificationCategories}
			labels={groupNotificationCategories}
		/>
		<h1
			class="ml-2 text-3xl hover:text-gray-800 cursor-pointer"
			on:click={() => (selectedPage = 'flow')}
		>
			{group.name}
		</h1>
	</div>
	<div class="flex items-center">
		<p class="text-xl hover:text-gray-800 cursor-pointer" on:click={() => (selectedPage = 'members')}>
			{memberCount}
			{$_('members')}
		</p>
		{#if typeof window !== "undefined"}
		{#if group.public}
			<HeaderIcon icon={faGlobeEurope} text="Public" Class="cursor-auto" />
		{:else}
			<HeaderIcon icon={faLock} text="Private" Class="cursor-auto"/>
		{/if}
		{/if}
	</div>
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

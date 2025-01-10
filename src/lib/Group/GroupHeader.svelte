<script lang="ts">
	import type { GroupDetails, SelectablePage } from './interface';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import { faLock } from '@fortawesome/free-solid-svg-icons/faLock';
	import { faGlobeEurope } from '@fortawesome/free-solid-svg-icons/faGlobeEurope';
	import DefaultBanner from '$lib/assets/default_banner_group.png';
	import { env } from '$env/dynamic/public';
	import Fa from 'svelte-fa';
	import { elipsis } from '$lib/Generic/GenericFunctions';
	import Description from '$lib/Poll/Description.svelte';

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

<div class="relative">
	<img
		class="cover w-full"
		src={group.cover_image
			? `${env.PUBLIC_API_URL}${env.PUBLIC_IMAGE_HAS_API === 'TRUE' ? '/api' : ''}${
					group.cover_image
			  }`
			: DefaultBanner}
		alt="cover"
	/>
	<img
		class="h-36 w-36 absolute -bottom-8 left-[15%] md:left-[25%] profile rounded-full"
		src={group.image
			? `${env.PUBLIC_API_URL}${env.PUBLIC_IMAGE_HAS_API === 'TRUE' ? '/api' : ''}${group.image}`
			: DefaultBanner}
		alt="profile"
	/>
</div>
<!-- TODO: Fix layout design -->
<div class="bg-white dark:bg-darkobject dark:text-darkmodeText pt-12 px-4 pb-4">
	<div class=" flex justify-evenly align-middle">
		<div class="flex items-center relative" id="notifications-list-group">
			<NotificationOptions
				type="group"
				api={`group/${$page.params.groupId}`}
				id={Number($page.params.groupId)}
				categories={groupNotificationCategories}
				labels={groupNotificationCategories}
				Class="mt-auto"
			/>

			<button
				class="ml-2 text-3xl hover:text-gray-800 dark:hover:text-gray-400 cursor-pointer"
				on:click={() => (selectedPage = 'flow')}
			>
				{group.name}
			</button>
		</div>
		<div class="flex items-center">
			<button
				class="text-xl hover:text-gray-800 dark:hover:text-gray-400 cursor-pointer"
				on:click={() => (selectedPage = 'members')}
			>
				{memberCount}
				{$_('members')}
			</button>
			<div class="ml-3">
				{#if typeof window !== 'undefined'}
					{#if group.public}
						<Fa icon={faGlobeEurope} />
					{:else}
						<Fa icon={faLock} />
					{/if}
				{/if}
			</div>
		</div>
	</div>
	{#if group.description.length > 0}
		<div class="mb-2 mt-6 mx-auto w-[50%] grid-area-description break-all">
			<Description limit={400} description={group.description} />
		</div>
	{/if}
</div>

<style>
	img.cover {
		aspect-ratio: 5;
		/* width: 100%; */
	}

	img.profile {
		width: 100px;
		height: 100px;
	}
</style>

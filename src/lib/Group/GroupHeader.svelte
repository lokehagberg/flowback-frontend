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
	import Button from '$lib/Generic/Button.svelte';
	import { faArrowLeft, faPen } from '@fortawesome/free-solid-svg-icons';
	import { PUBLIC_ONE_GROUP_FLOWBACK } from '$env/static/public';

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

<div class="bg-white dark:bg-darkobject">
	<div class="relative">
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

			{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
				<Button
					action={() => history.back()}
					Class="absolute left-0 top-0 p-3 m-4 transition-all bg-gray-200 dark:bg-darkobject hover:brightness-95 active:brightness-90"
				>
					<div class="text-gray-800 dark:text-gray-200">
						<Fa icon={faArrowLeft} />
					</div>
				</Button>
			{/if}

			<Button
				hoverEffect={false}
				Class="absolute right-0 top-0 p-3 m-4 transition-all bg-gray-200 dark:bg-darkobject"
			>
				<NotificationOptions
					hoverEffect={false}
					type="group"
					api={`group/${$page.params.groupId}`}
					id={Number($page.params.groupId)}
					categories={groupNotificationCategories}
					labels={groupNotificationCategories}
					Class="text-gray-800 dark:text-gray-200"
					ClassOpen="-left-[90px]"
				/>
			</Button>
		</div>

		<img
			class="h-36 w-36 absolute -bottom-12 left-[10%] md:left-[12%] profile rounded-full"
			src={group.image
				? `${env.PUBLIC_API_URL}${env.PUBLIC_IMAGE_HAS_API === 'TRUE' ? '/api' : ''}${group.image}`
				: DefaultBanner}
			alt="profile"
		/>
	</div>

	<div class="dark:bg-darkobject dark:text-darkmodeText w-[55%] mx-auto py-4">
		<div class="">
			<div class="flex align-baseline items-baseline relative" id="notifications-list-group">
				<button
					class="text-xl hover:text-gray-800 dark:hover:text-gray-400 cursor-pointer"
					on:click={() => (selectedPage = 'flow')}
				>
					{group.name}
				</button>
				<button
					class="text-sm ml-6 hover:text-gray-800 dark:hover:text-gray-400 cursor-pointer"
					on:click={() => (selectedPage = 'members')}
				>
					{memberCount}
					{$_('members')}
				</button>
				<div class="ml-2">
					{#if typeof window !== 'undefined' && !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE')}
						{#if group.public}
							<Fa icon={faGlobeEurope} size={'xs'} />
						{:else}
							<Fa icon={faLock} />
						{/if}
					{/if}
				</div>
			</div>
		</div>
		{#if group.description.length > 0}
			<div class="text-xs mt-2 pb-1 grid-area-description break-all">
				<Description limit={400} description={group.description} />
			</div>
		{/if}
	</div>
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

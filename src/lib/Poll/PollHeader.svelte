<script lang="ts">
	import type { Phase, poll } from './interface';
	import { page } from '$app/stores';
	import Tag from '$lib/Group/Tag.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import { faAlignLeft } from '@fortawesome/free-solid-svg-icons/faAlignLeft';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import { onThumbnailError } from '$lib/Generic/GenericFunctions';
	import DefaultBanner from '$lib/assets/default_banner_group.png';
	import { env } from '$env/dynamic/public';
	import Fa from 'svelte-fa';
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import { getPhaseUserFriendlyName } from './functions';
	import { _ } from 'svelte-i18n';

	export let poll: poll,
		displayTag = false,
		phase: Phase;
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<!-- svelte-ignore a11y-click-events-have-key-events -->

<div
	class=" bg-white dark:bg-darkobject dark:text-darkmodeText rounded shadow flex flex-col w-full"
>
	<div
		class="cursor-pointer bg-white dark:bg-darkobject dark:text-darkmodeText rounded shadow flex flex-col gap-8 w-full"
		on:click={() => goto(`/groups/${$page.params.groupId}`)}
	>
		<!-- NOTE: In +layout, rote folder, there are URL related behaviours which are affected by this. -->
		<Fa icon={faArrowLeft} />
	</div>
	<div class="flex h-8 justify-between items-center">
		<div class="flex items-baseline">
			{#if displayTag}
				<Tag Class="w-32" tag={{ name: poll.tag_name, id: poll.tag_id, active: true, imac: 0 }} />
			{/if}
			{#if poll.poll_type === 4}
				<!-- TODO make it easy to change poll types e.t.c -->
				<HeaderIcon Class="p-2 pl-2 cursor-default" icon={faAlignLeft} text={'Text Poll'} />
			{:else if poll.poll_type === 3}
				<HeaderIcon Class="p-2 pl-2 cursor-default" icon={faCalendarAlt} text={'Date Poll'} />
			{/if}
			<!-- Group Profile -->
			{#if import.meta.env.VITE_ONE_GROUP_FLOWBACK !== 'TRUE'}
				<a
					href={`/groups/${$page.params.groupId}`}
					class:hover:underline={poll.group_joined}
					class="text-black dark:text-darkmodeText"
				>
					<img
						class="h-8 w-8 inline rounded-full"
						src={`${env.PUBLIC_API_URL}${poll.group_image}`}
						alt="group thumbnail"
						on:error={(e) => onThumbnailError(e, DefaultBanner)}
					/>
					<span class="inline">{poll.group_name}</span>
				</a>
			{/if}
		</div>
		<!-- <HeaderIcon Class="p-2 cursor-default" icon={faHourglass} text={'End date'} /> -->
		<NotificationOptions
			id={poll.id}
			api={`group/poll/${poll.id}`}
			categories={['poll', 'timeline', 'comments_all']}
			labels={['Poll', 'Timeline', 'Comments']}
		/>
	</div>
	<h1 class="text-left text-5xl mt-auto mb-auto">{poll.title}</h1>
	{#if poll.description.length > 0}
		<div
			class="border border-gray-200 dark:border-gray-500 rounded p-4 whitespace-pre-wrap break-words"
			id="poll-description"
		>
			{poll.description}
		</div>
	{/if}
	{#if poll.attachments && poll.attachments.length > 0}
		<img
			src={`${import.meta.env.VITE_API}/api/media/${poll.attachments[0].file}` || ''}
			alt="attachment to the poll"
		/>
	{/if}

	<!-- Current Phase -->
	<div>
		{$_('Current phase:')}
		{getPhaseUserFriendlyName(phase)}
	</div>
</div>

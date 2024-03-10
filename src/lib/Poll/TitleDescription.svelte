<script lang="ts">
	import type { poll } from './interface';
	import { page } from '$app/stores';
	import Tag from '$lib/Group/Tag.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import { faAlignLeft } from '@fortawesome/free-solid-svg-icons/faAlignLeft';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import {env} from "$env/dynamic/public";

	export let poll: poll, pollType: number;
</script>

<h1 class="text-left text-5xl p-4 mt-auto mb-auto">{poll.title}</h1>
<div
	class="border border-gray-200 dark:border-gray-500 rounded p-4 whitespace-pre-wrap break-words"
	id="poll-description"
>
	{poll.description}
	<div class="flex h-8 justify-between">
		<div class="flex items-baseline">
			<Tag Class="w-32" tag={{ name: poll.tag_name, id: poll.tag, active: true }} />
			{#if pollType === 4}
				<!-- TODO make it easy to change poll types e.t.c -->
				<HeaderIcon Class="p-2 pl-2 cursor-default" icon={faAlignLeft} text={'Text Poll'} />
			{:else if pollType === 3}
				<HeaderIcon Class="p-2 pl-2 cursor-default" icon={faCalendarAlt} text={'Scheduled Poll'} />
			{/if}
			<!-- Group Profile -->
			<a
				href={`/groups/${$page.params.groupId}`}
				class:hover:underline={poll.group_joined}
				class="text-black"
			>
				<img
					class="h-8 w-8 inline rounded-full"
					src={`${env.PUBLIC_API_URL}${poll.group_image}`}
					alt="group thumbnail"
				/>
				<span class="inline">{poll.group_name}</span>
			</a>
		</div>
		<!-- <HeaderIcon Class="p-2 cursor-default" icon={faHourglass} text={'End date'} /> -->
		<NotificationOptions
			id={poll.id}
			api={`group/poll/${poll.id}`}
			categories={['poll', 'timeline']}
			labels={['Poll', 'Timeline']}
		/>
	</div>
</div>

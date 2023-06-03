<script lang="ts">
	import Timeline from './Timeline.svelte';
	import type { poll } from './interface';
	import { page } from '$app/stores';
	import Tag from '$lib/Group/Tag.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import { faHourglass } from '@fortawesome/free-solid-svg-icons/faHourglass';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { _ } from 'svelte-i18n';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import { faThumbtack } from '@fortawesome/free-solid-svg-icons/faThumbtack';
	import { faComment } from '@fortawesome/free-solid-svg-icons/faComment';
	import { faAlignLeft } from '@fortawesome/free-solid-svg-icons/faAlignLeft';

	export let poll: poll,
		isAdmin = false;

	let onHoverGroup = false;

	const pinPoll = async () => {
		const { res, json } = await fetchRequest('POST', `group/poll/${poll.id}/update`, {
			pinned: !poll.pinned
		});
		if (res.ok) poll.pinned = !poll.pinned;
	};
</script>

<div class="bg-white dark:bg-darkobject dark:text-darkmodeText pt-2 pl-5 pr-5 shadow-lg rounded-md transition-all vote-thumbnail">
	<div class="flex items-center justify-between mt-1">
		<div>
			<Tag tag={poll.tag_name} Class="inline cursor-default" />
			<div class="ml-2 inline-flex">
				{#if poll.poll_type === 1}
					<HeaderIcon Class="p-2 pl-0 cursor-default" icon={faAlignLeft} text={'Text Poll'} />
				{:else if poll.poll_type === 3}
					<HeaderIcon
						Class="p-2 pl-0 cursor-default"
						icon={faCalendarAlt}
						text={'Scheduled Poll'}
					/>
				{/if}
				<!-- <HeaderIcon Class="p-2 cursor-default" icon={faHourglass} text={'End date'} /> -->
			</div>
			{#if isAdmin || poll.pinned}
				<div class="inline" class:cursor-pointer={isAdmin} on:click={pinPoll}>
					<Fa
						icon={faThumbtack}
						color={poll.pinned ? 'Black' : '#BBB'}
						rotate={poll.pinned ? '0' : '90'}
					/>
				</div>
			{/if}
		</div>
		<a
			href={poll.group_joined ? `groups/${poll.group_id}` : ''}
			class:hover:underline={poll.group_joined}
			class="text-black dark:text-darkmodeText"
		>
			<img
				class="h-8 w-8 inline rounded-full"
				src={`${import.meta.env.VITE_API}${poll.group_image}`}
				alt="group thumbnail"
			/>
			<span class="inline">{poll.group_name}</span>
		</a>
	</div>
	<div class="flex justify-between items-center text-black dark:text-darkmodeText relative">
		<a
			class="cursor-pointer "
			href={onHoverGroup
				? '/groups/1'
				: `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`}
		>
			<h1 class="text-left text-xl p-1 pl-0 dark:text-darkmodeText">{poll.title}</h1>
		</a>
		<NotificationOptions
			id={poll.id}
			api={`group/poll/${poll.id}`}
			categories={['poll', 'timeline', 'comment_all']}
			labels={['Poll', 'Timeline', 'Comments']}
		/>
	</div>
	<a
		class="cursor-pointe"
		href={onHoverGroup
			? '/groups/1'
			: `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`}
	>
		<p class="mt-2 whitespace-pre-wrap break-words mb-4 dark:text-darkmodeText">
			{poll.description}
		</p></a
	>

	<Timeline
		displayDetails={false}
		Class="border-none pointer-default"
		dates={[
			new Date(poll.start_date),
			new Date(poll.proposal_end_date),
			new Date(poll.vote_start_date),
			new Date(poll.delegate_vote_end_date),
			new Date(poll.end_date)
		]}
	/>
	<div class="flex justify-between text-sm text-gray-600 dark:text-darkmodeText mt-2 pointer-default">
		<p
			class="hover:underline"
			on:mouseover={() => (onHoverGroup = true)}
			on:mouseleave={() => (onHoverGroup = false)}
			on:click={() => (window.location.href = '/groups/1')}
			on:focus
		/>
	</div>
	<div class="hover:bg-gray-100 cursor-pointer text-sm text-gray-600 dark:text-darkmodeText px-1 mb-2">
		<a
			class="text-black dark:text-darkmodeText"
			href={onHoverGroup
				? '/groups/1'
				: `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}?section=comments`}
		>
			<Fa class="inline" icon={faComment} />
			<span class="inline">{poll.total_comments} {$_('comments')}</span>
		</a>
	</div>
</div>

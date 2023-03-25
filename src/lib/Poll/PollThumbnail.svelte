<script lang="ts">
	import Timeline from './Timeline.svelte';
	import type { poll } from './interface';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import Tag from '$lib/Group/Tag.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import { faArrowUp } from '@fortawesome/free-solid-svg-icons/faArrowUp';
	import { faArrowDown } from '@fortawesome/free-solid-svg-icons/faArrowDown';
	import { faHourglass } from '@fortawesome/free-solid-svg-icons/faHourglass';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import { faBell } from '@fortawesome/free-solid-svg-icons/faBell';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { _ } from 'svelte-i18n';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';

	export let poll: poll;

	onMount(() => {
		window.addEventListener('click', function (e) {
			if (
				notificationOpen &&
				//@ts-ignore
				!document.getElementById(`notification-list-${poll.id}`)?.contains(e.target)
			) {
				notificationOpen = false;
			}
		});
	});
	let onHoverGroup = false,
		notificationOpen = false;

	type notificationCategory = 'poll' | 'timeline';

	const handleNotificationSubscription = async (categories: notificationCategory[]) => {
		notificationOpen = !notificationOpen;
		// const {res, json} = await fetchRequest('POST', `group/${poll.group_id}/poll/${poll.id}/unsubscribe`)
		await fetchRequest('POST', `group/${poll.group_id}/poll/${poll.id}/subscribe`, { categories });
	};
</script>

<!-- href={onHoverGroup ? (window.location.href = '/groups/1') : (window.location.href = '/poll')} -->
<div class="bg-white pt-2 pl-5 pr-5 shadow-lg rounded-md transition-all vote-thumbnail">
	<div class="flex justify-between items-center text-black relative">
		<a
			class="hover:shadow-xl hover:rounded-xl cursor-pointer "
			href={onHoverGroup
				? '/groups/1'
				: `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`}
		>
			<h1 class="text-left text-xl p-1 pl-0">{poll.title}</h1>
		</a>
		<NotificationOptions api={`group/${poll.group_id}/poll/${poll.id}/subscribe`} categories={["poll", "timeline"]} labels={["Poll", "Timeline"]}/>
		<!-- <div
			class="hover:text-primary hover:cursor-pointer"
			id={`notification-list-${poll.id}`}
			on:click={() => (notificationOpen = !notificationOpen)}
		>
			<Fa icon={faBell} size={'1.2x'} />
		</div>
		{#if notificationOpen}
			<ul class="absolute -right-[40%] bottom-0 bg-white shadow text-sm">
				<li
					class="hover:cursor-pointer hover:shadow p-1 hover:bg-gray-100 transition-all"
					on:click={() => handleNotificationSubscription(['poll', 'timeline'])}
				>
					{$_('All notifications')}
				</li>
				<li
					class="hover:cursor-pointer hover:shadow p-1 hover:bg-gray-100 transition-all"
					on:click={() => handleNotificationSubscription(['timeline'])}
				>
					{$_('Only timeline')}
				</li>
				<li
					class="hover:cursor-pointer hover:shadow p-1 hover:bg-gray-100 transition-all"
					on:click={() => handleNotificationSubscription([])}
				>
					{$_('Cancel notifications')}
				</li>
			</ul>
		{/if} -->
	</div>
	<div class="flex items-center justify-between mt-1">
		<Tag tag={poll.tag_name} Class="inline cursor-default" />
		<div class="flex">
			{#if poll.poll_type === 1}
				<HeaderIcon
					Class="p-2 pl-0 cursor-default"
					icons={[faArrowUp, faArrowDown]}
					text={'Ranking'}
				/>
			{:else if poll.poll_type === 3}
				<HeaderIcon Class="p-2 pl-0 cursor-default" icon={faCalendarAlt} text={'Scheduled'} />
			{/if}
			<HeaderIcon Class="p-2 cursor-default" icon={faHourglass} text={'End date'} />
		</div>
		<a
			href={poll.group_joined ? `groups/${poll.group_id}` : ''}
			class:hover:underline={poll.group_joined}
			class="text-black"
		>
			<img
				class="h-8 w-8 inline rounded-full"
				src={`${import.meta.env.VITE_API}${poll.group_image}`}
				alt="group thumbnail"
			/>
			<span class="inline">{poll.group_name}</span>
		</a>
	</div>
	<p class="mt-2 whitespace-pre-wrap mb-4 ">
		{poll.description}
	</p>

	<Timeline
		displayDetails={false}
		Class="border-none pointer-default"
		dates={[
			new Date(poll.start_date),
			new Date(poll.proposal_end_date),
			new Date(poll.delegate_vote_end_date),
			new Date(poll.end_date)
		]}
	/>
	<div class="flex justify-between text-sm text-gray-600 mt-2 pointer-default">
		<p
			class="hover:underline"
			on:mouseover={() => (onHoverGroup = true)}
			on:mouseleave={() => (onHoverGroup = false)}
			on:click={() => (window.location.href = '/groups/1')}
			on:focus
		/>
	</div>
</div>

<style>
	.vote-thumbnail:hover {
		outline: 2px #ccc solid;
	}
</style>

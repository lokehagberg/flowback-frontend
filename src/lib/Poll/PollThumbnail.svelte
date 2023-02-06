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

	export let poll: poll;

	onMount(() => {
		// console.log(poll, 'POLL');
	});
	let onHoverGroup = false;
</script>

<!-- href={onHoverGroup ? (window.location.href = '/groups/1') : (window.location.href = '/poll')} -->
<div
	class="bg-white pt-2 pl-5 pr-5 shadow-lg rounded-md transition-all vote-thumbnail"
>
	<a
	class="hover:shadow-xl hover:rounded-xl cursor-pointer "
		href={onHoverGroup
			? '/groups/1'
			: `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`}
	>
		<h1 class="text-left text-xl p-1 pl-0">{poll.title}</h1>
		<div class="border border-gray-200 p-2">
			<div class="flex items-center justify-between">
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
				<a href={poll.joined ? `groups/${poll.group_id}` : ""} class:hover-underline={poll.joined} class="text-black" >
					<img
						class="h-8 w-8 inline rounded-full"
						src={`${import.meta.env.VITE_API}${poll.group_image}`}
						alt="group thumbnail"
					/>
					<span class="inline">{poll.group_name}</span>
				</a>
			</div>
		</div>
		<p class="mt-2 whitespace-pre-wrap border border-gray-200 p-3">
			{poll.description}
		</p>
	</a>
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

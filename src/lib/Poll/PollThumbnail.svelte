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
		console.log(poll, 'POLL');
	});
	let onHoverGroup = false;
</script>

<!-- href={onHoverGroup ? (window.location.href = '/groups/1') : (window.location.href = '/poll')} -->
<a
	class="bg-white pt-2 pl-6 pr-6 pb-2 shadow-lg rounded cursor-pointer vote-thumbnail hover:shadow-xl hover:rounded-xl transition transition-all"
	href={onHoverGroup
		? '/groups/1'
		: `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`}
>
	<h1 class="text-left text-3xl p-2 pl-0">{poll.title}</h1>
	<Tag tag={poll.tag_name} Class="inline" />
	<div class="flex inline">
		{#if poll.poll_type === 1}
			<HeaderIcon Class="p-2 pl-0" icons={[faArrowUp, faArrowDown]} text={'Ranking'} />
		{:else if poll.poll_type === 3}
			<HeaderIcon Class="p-2 pl-0" icon={faCalendarAlt} text={'Scheduled'} />
		{/if}
		<HeaderIcon Class="p-2" icon={faHourglass} text={'End date'} />
	</div>
	<p class="mt-2 whitespace-pre-wrap">
		{poll.description}
	</p>
	<Timeline
		Class="border-none"
		dates={[
			new Date(poll.start_date),
			new Date(poll.proposal_end_date),
			new Date(poll.delegate_vote_end_date),
			new Date(poll.end_date)
		]}
	/>
	<div class="flex justify-between text-sm text-gray-600 mt-2">
		<p
			class="hover:underline"
			on:mouseover={() => (onHoverGroup = true)}
			on:mouseleave={() => (onHoverGroup = false)}
			on:click={() => (window.location.href = '/groups/1')}
			on:focus
		/>
	</div>
</a>

<style>
	.vote-thumbnail:hover {
		outline: 2px #ccc solid;
	}
</style>

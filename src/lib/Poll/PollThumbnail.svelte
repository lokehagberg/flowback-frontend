<script lang="ts">
	import Timeline from './Timeline.svelte';
	import type { Phase, poll } from './interface';
	import { page } from '$app/stores';
	import Tag from '$lib/Group/Tag.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { _ } from 'svelte-i18n';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import { faThumbtack } from '@fortawesome/free-solid-svg-icons/faThumbtack';
	import { faComment } from '@fortawesome/free-solid-svg-icons/faComment';
	import { faAlignLeft } from '@fortawesome/free-solid-svg-icons/faAlignLeft';
	import { onDestroy, onMount } from 'svelte';
	import { getPhase, getPhaseUserFriendlyName } from './functions';
	import { goto } from '$app/navigation';
	import DefaultBanner from '$lib/assets/default_banner_group.png';
	import { onThumbnailError } from '$lib/Generic/GenericFunctions';
	import Select from '$lib/Generic/Select.svelte';
	import { getTags } from '$lib/Group/functions';
	import type { Tag as TagType } from '$lib/Group/interface';
	import { env } from '$env/dynamic/public';
	import { darkModeStore } from '$lib/Generic/DarkMode';
	import Button from '$lib/Generic/Button.svelte';
	import Description from './Description.svelte';

	export let poll: poll,
		isAdmin = false;

	let onHoverGroup = false,
		phase: Phase,
		// If text poll, have all phases. Date polls have fewer phases to display
		dates: Date[],
		tags: TagType[] = [],
		selectedTag: number,
		darkMode: boolean,
		voting = true;

	const pinPoll = async () => {
		const { json, res } = await fetchRequest('POST', `group/poll/${poll.id}/update`, {
			pinned: !poll.pinned
		});
		if (res.ok) poll.pinned = !poll.pinned;
	};

	const submitTagVote = async (tag: number) => {
		const { json, res } = await fetchRequest('POST', `group/poll/${poll.group_id}/area/update`, {
			tag,
			vote: true
		});

		if (!res.ok) return;

		voting = false;
	};

	onMount(async () => {
		phase = getPhase(poll);
		if (phase === 'area_vote') tags = await getTags(poll.group_id);

		darkModeStore.subscribe((dark) => (darkMode = dark));
	});

	$: if (poll)
		dates =
			poll.poll_type === 4
				? [
						new Date(poll.start_date),
						new Date(poll.area_vote_end_date),
						new Date(poll.proposal_end_date),
						new Date(poll.prediction_statement_end_date),
						new Date(poll.prediction_bet_end_date),
						new Date(poll.delegate_vote_end_date),
						new Date(poll.end_date)
				  ]
				: [new Date(poll.start_date), new Date(poll.end_date)];
</script>

<div
	class="bg-white dark:bg-darkobject dark:text-darkmodeText pt-2 pl-5 pr-5 poll-thumbnail-shadow rounded-md transition-all vote-thumbnail"
	class:poll-thumbnail-shadow={!darkMode}
	class:poll-thumbnail-shadow-dark={darkMode}
	id={`poll-thumbnail-${poll.id.toString()}`}
>
	<div class="flex items-center justify-between mt-1">
		<div class="flex justify-between items-center text-black dark:text-darkmodeText relative">
			<a
				class="cursor-pointer text-black"
				href={onHoverGroup
					? '/groups/1'
					: `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`}
			>
				<h1
					class="text-left text-3xl mb-3 text-blue-800 p-1 pl-0 dark:text-darkmodeText hover:underline"
				>
					{poll.title}
				</h1>
			</a>
		</div>
		<div class="ml-2 inline-flex gap-3 items-center">
			{#if !(import.meta.env.VITE_ONE_GROUP_FLOWBACK === 'TRUE') && !$page.params.groupId}
				<a
					href={poll.group_joined ? `groups/${poll.group_id}` : ''}
					class:hover:underline={poll.group_joined}
					class="text-black dark:text-darkmodeText"
				>
					<span class="inline">{poll.group_name}</span>
					<img
						class="h-8 w-8 inline rounded-full"
						src={`${import.meta.env.VITE_API}${
							import.meta.env.VITE_IMAGE_HAS_API === 'TRUE' ? '/api' : ''
						}${poll.group_image}`}
						on:error={(e) => onThumbnailError(e, DefaultBanner)}
						alt={'Poll Thumbnail'}
					/>
				</a>
			{/if}
			<!-- <HeaderIcon Class="p-2 cursor-default" icon={faHourglass} text={'End date'} /> -->
			<NotificationOptions
				id={poll.id}
				api={`group/poll/${poll.id}`}
				categories={['poll', 'timeline', 'comment_all']}
				labels={['Poll', 'Timeline', 'Comments']}
			/>
			{#if isAdmin || poll.pinned}
				<!-- svelte-ignore a11y-no-static-element-interactions -->
				<div class="" class:cursor-pointer={isAdmin} on:click={pinPoll} on:keydown>
					<Fa
						size="1.2x"
						icon={faThumbtack}
						color={poll.pinned ? '#999' : '#CCC'}
						rotate={poll.pinned ? '0' : '90'}
					/>
				</div>
			{/if}
		</div>
	</div>
	<div class="flex gap-2">
		{#if poll.poll_type === 4}
			<HeaderIcon
				Class="!p-0 !cursor-default"
				icon={faAlignLeft}
				text={'Text Poll'}
				color={localStorage.getItem('theme') === 'dark' ? 'white' : 'black'}
			/>
		{:else if poll.poll_type === 3}
			<HeaderIcon
				Class="!p-0 !cursor-default"
				icon={faCalendarAlt}
				text={'Date Poll'}
				color={localStorage.getItem('theme') === 'dark' ? 'white' : 'black'}
			/>
		{/if}
		<div
			class="hover:bg-gray-100 dark:hover:bg-slate-500 cursor-pointer text-sm text-gray-600 dark:text-darkmodeText"
		>
			<a
				class="text-black dark:text-darkmodeText"
				href={onHoverGroup
					? '/groups/1'
					: `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}?section=comments`}
			>
				<Fa class="inline" icon={faComment} />
				<span class="inline">{poll.total_comments}</span>
			</a>
		</div>
		<Tag
			tag={{ name: poll.tag_name, id: poll.tag_id, active: true, imac: 0 }}
			Class="inline cursor-default"
		/>
		<div class="text-sm">{$_('Current phase:')} {getPhaseUserFriendlyName(phase)}</div>
	</div>

	<Description limit={500} {poll} {onHoverGroup} />

	<Timeline displayDetails={false} pollType={poll.poll_type} bind:dates />

	<!-- Area Voting -->
	{#if phase === 'area_vote'}
		<form on:submit|preventDefault={() => submitTagVote(selectedTag)} class="flex justify-around">
			<Select
				label={''}
				labels={tags.map((tag) => tag.name)}
				values={tags.map((tag) => tag.id)}
				bind:value={selectedTag}
				classInner="w-full bg-white p-6 border-gray-400 rounded-md border-2"
				Class="w-[45%]"
			/>
			{#if voting}
				<Button type="submit" Class="w-[45%]">Save Vote</Button>
			{:else}
				<p class="w-[45%] text-center pt-6">Successfully saved voting!</p>
			{/if}
		</form>
	{/if}

	<div
		class="flex justify-between text-sm text-gray-600 dark:text-darkmodeText mt-2 pointer-default"
	>
		<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
		<p
			class="hover:underline"
			on:mouseover={() => (onHoverGroup = true)}
			on:mouseleave={() => (onHoverGroup = false)}
			on:click={() => goto('/groups/1')}
			on:focus
			on:keydown
		/>
	</div>
</div>

<style>
	.poll-thumbnail-shadow {
		box-shadow: 0 0 5px rgb(203, 203, 203);
	}

	.poll-thumbnail-shadow-dark {
		box-shadow: 0 0 10px rgb(24, 24, 24);
	}
</style>

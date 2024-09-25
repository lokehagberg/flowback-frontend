<script lang="ts">
	import Timeline from './TimelineLegacy.svelte';
	import type { Phase, poll } from './interface';
	import { page } from '$app/stores';
	import Tag from '$lib/Group/Tag.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { _ } from 'svelte-i18n';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import { onMount } from 'svelte';
	import { getPhase, getPhaseUserFriendlyName } from './functions';
	import DefaultBanner from '$lib/assets/default_banner_group.png';
	import { onThumbnailError } from '$lib/Generic/GenericFunctions';
	import Select from '$lib/Generic/Select.svelte';
	import { getTags } from '$lib/Group/functions';
	import type { Tag as TagType } from '$lib/Group/interface';
	import { darkModeStore } from '$lib/Generic/DarkMode';
	import Button from '$lib/Generic/Button.svelte';
	import Description from './Description.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import { env } from '$env/dynamic/public';
	import {
		faAnglesRight,
		faThumbtack,
		faComment,
		faAlignLeft,
		faCalendarAlt,
		// faDash
	} from '@fortawesome/free-solid-svg-icons';
	// import { FaLayers } from 'svelte-fa';

	export let poll: poll,
		isAdmin = false;

	let onHoverGroup = false,
		phase: Phase,
		// If text poll, have all phases. Date polls have fewer phases to display
		dates: Date[],
		tags: TagType[] = [],
		selectedTag: number,
		darkMode: boolean,
		voting = true,
		poppup: poppup;

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

		if (!res.ok) {
			poppup = { message: 'Could not submit tag vote', success: false };
			return;
		}

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
	class="bg-white dark:bg-darkobject dark:text-darkmodeText poll-thumbnail-shadow rounded-md p-4"
	class:poll-thumbnail-shadow={!darkMode}
	class:poll-thumbnail-shadow-dark={darkMode}
	id={`poll-thumbnail-${poll.id.toString()}`}
>
	<div class="flex items-center justify-between text-primary">
		<a
			class="cursor-pointer text-primary dark:text-darkmodeText hover:underline text-2xl"
			href={onHoverGroup
				? '/groups/1'
				: `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`}
		>
			{poll.title}
		</a>

		<div class="inline-flex items-center gap-4">
			{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE') && !$page.params.groupId}
				<a
					href={poll.group_joined ? `groups/${poll.group_id}` : ''}
					class:hover:underline={poll.group_joined}
					class="text-black dark:text-darkmodeText"
				>
					<span class="inline">{poll.group_name}</span>
					<img
						class="h-8 w-8 inline rounded-full"
						src={`${env.PUBLIC_API}${env.PUBLIC_IMAGE_HAS_API === 'TRUE' ? '/api' : ''}${
							poll.group_image
						}`}
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
				Class="text-black"
			/>
			{#if isAdmin || poll.pinned}
				<div
					class=""
					class:cursor-pointer={isAdmin}
					on:click={pinPoll}
					on:keydown
					tabindex="0"
					role="button"
				>
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

	<div class="flex gap-4 mt-1 items-center">
		<!-- Poll Type Icons -->
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

		<!-- Fast Forward Icon -->
		{#if poll.allow_fast_forward}
			<HeaderIcon
				Class="!p-0 !cursor-default flex"
				icon={faAnglesRight}
				text={'Fast Forward'}
				color={localStorage.getItem('theme') === 'dark' ? 'white' : 'black'}
			/>
			{:else}
			<!-- <FaLayers>
				<Fa icon={faAnglesRight}/>
				<Fa icon={faDash} />
			</FaLayers> -->
		{/if}

		<!-- Comment icon. When user clicks it leads to the comment section on the poll -->
		<a
			class="flex gap-1 items-center text-black dark:text-darkmodeText hover:bg-gray-100 dark:hover:bg-slate-500 cursor-pointer text-sm"
			href={onHoverGroup
				? '/groups/1'
				: `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}?section=comments`}
		>
			<Fa class="inline" icon={faComment} />
			<span class="inline">{poll.total_comments}</span>
		</a>

		<!-- Phase -->
		<Tag
			tag={{ name: poll.tag_name, id: poll.tag_id, active: true, imac: 0 }}
			Class="inline cursor-default"
		/>
		<div class="text-sm">{$_('Current phase:')} {getPhaseUserFriendlyName(phase)}</div>
	</div>

	{#if poll.description.length > 0}
		<Description limit={500} {poll} {onHoverGroup} Class="mt-2" />
	{/if}

	<Timeline Class="mt-2" displayDetails={false} pollType={poll.poll_type} bind:dates />

	<div class="!mt-4">
		<!-- Area Voting -->
		{#if phase === 'area_vote'}
			<form
				on:submit|preventDefault={() => submitTagVote(selectedTag)}
				class="flex justify-between"
			>
				<Select
					label={''}
					labels={tags.map((tag) => tag.name)}
					values={tags.map((tag) => tag.id)}
					bind:value={selectedTag}
					classInner="w-full !p-1 bg-white p-4 border-gray-400 rounded-md border-2"
					Class="w-[47%] "
				/>
				{#if voting}
					<Button type="submit" Class="w-[47%] !p-0" buttonStyle="primary-light">Save Vote</Button>
				{:else}
					<p class="w-[47%] text-center">Successfully saved voting!</p>
				{/if}
			</form>
		{:else if phase === 'proposal'}
			<div class="flex justify-between">
				<Button Class="w-[47%]" buttonStyle="primary-light"
					>See Proposals ({poll.total_proposals})</Button
				>
				<Button Class="w-[47%]" buttonStyle="primary-light">Create a Proposal</Button>
			</div>
		{:else if phase === 'prediction_statement'}
			<div class="flex justify-between">
				<Button Class="w-[47%]" buttonStyle="primary-light"
					>See Predictions ({poll.total_predictions})</Button
				>
				<Button Class="w-[47%]" buttonStyle="primary-light">Create a Prediction</Button>
			</div>
		{:else if phase === 'prediction_bet'}
			<div class="flex justify-between">
				<Button Class="w-[47%]" buttonStyle="primary-light">Mange bets</Button>
				<p class="w-[47%]">You have not betted yet!</p>
			</div>
		{:else if phase === 'delegate_vote' || phase === 'vote'}
			<div class="flex justify-between">
				<Button Class="w-[47%]" buttonStyle="primary-light">Mange votes</Button>
				<p class="w-[47%]">You have not voted yet!</p>
			</div>
		{:else if phase === 'prediction_vote' || phase === 'result'}
			<div class="flex justify-between">
				<Button Class="w-[47%]" buttonStyle="primary-light">View detailed results</Button>
				<Button Class="w-[47%]" buttonStyle="primary-light">Evaluate predictions</Button>
			</div>
		{/if}
	</div>
</div>

<Poppup bind:poppup />

<style>
	.poll-thumbnail-shadow {
		box-shadow: 0 0 5px rgb(203, 203, 203);
	}

	.poll-thumbnail-shadow-dark {
		box-shadow: 0 0 10px rgb(24, 24, 24);
	}
</style>

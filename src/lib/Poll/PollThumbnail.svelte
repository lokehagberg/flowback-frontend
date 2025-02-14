<script lang="ts">
	//@ts-ignore
	import TimelineLegacy from './TimelineLegacy.svelte';
	import type { Phase, poll } from './interface';
	import { page } from '$app/stores';
	import Tag from '$lib/Group/Tag.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import Fa from 'svelte-fa';
	import { fetchRequest } from '$lib/FetchRequest';
	import { _ } from 'svelte-i18n';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import { onMount } from 'svelte';
	import { getPhase, getPhaseUserFriendlyName, nextPhase } from './functions';
	import DefaultBanner from '$lib/assets/default_banner_group.png';
	import { elipsis, onThumbnailError } from '$lib/Generic/GenericFunctions';
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
		faSlash
	} from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import MultipleChoices from '$lib/Generic/MultipleChoices.svelte';
	import DeletePollModal from './DeletePollModal.svelte';
	import ChatIcon from '$lib/assets/Chat_fill.svg';

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
		poppup: poppup,
		deletePollModalShow = false;

	//When adminn presses the pin tack symbol, pin the poll
	const pinPoll = async () => {
		const { json, res } = await fetchRequest('POST', `group/poll/${poll.id}/update`, {
			pinned: !poll.pinned
		});
		if (res.ok) poll.pinned = !poll.pinned;
	};

	const submitTagVote = async (tag: number) => {
		const { json, res } = await fetchRequest('POST', `group/poll/${poll.id}/area/update`, {
			tag,
			vote: true
		});

		if (!res.ok) {
			poppup = { message: 'Could not submit tag vote', success: false };
			return;
		}

		voting = false;
	};

	const getAreaVote = async () => {
		const { json, res } = await fetchRequest('GET', `group/poll/${poll.id}/area/list`);

		if (!res.ok) return;

		let selectedTagName = json.results.find((tag: Tag) => tag.user_vote === true)?.tags[0].tag_name;

		if (selectedTagName) {
			selectedTag = tags.find((tag) => tag.name === selectedTagName)?.id || 0; 
		}
	};


	onMount(async () => {
		phase = getPhase(poll);
		if (phase === 'area_vote') {
			tags = await getTags(poll.group_id);
			getAreaVote();
		} 

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
	<div class="mx-2">
		<div class="flex items-center justify-between text-primary dark:text-secondary">
			<a
				class="cursor-pointer text-primary dark:text-secondary hover:underline text-2xl break-all"
				href={onHoverGroup
					? '/groups/1'
					: `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`}
			>
				{elipsis(poll.title)}
			</a>

			<div class="inline-flex gap-4 items-baseline">
				{#if !(env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE') && !$page.params.groupId}
					<a
						href={poll.group_joined ? `groups/${poll.group_id}` : ''}
						class:hover:underline={poll.group_joined}
						class="text-black dark:text-darkmodeText"
					>
						<span class="inline break-all">{poll.group_name}</span>
						<img
							class="h-8 w-8 inline rounded-full break-all"
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
					type="poll"
					id={poll.id}
					api={`group/poll/${poll.id}`}
					categories={['poll', 'timeline', 'comment_all']}
					labels={['Poll', 'Timeline', 'Comments']}
					Class="text-black dark:text-darkmodeText"
					ClassOpen="right-0"
				/>
				{#if isAdmin || poll.pinned}
					<button class="" class:cursor-pointer={isAdmin} on:click={pinPoll}>
						<Fa
							size="1.2x"
							icon={faThumbtack}
							color={poll.pinned ? '#999' : '#CCC'}
							rotate={poll.pinned ? '0' : '45'}
						/>
					</button>
				{/if}

				<MultipleChoices
					labels={phase === 'result' || phase === 'prediction_vote'
						? [$_('Delete Poll')]
						: [$_('Delete Poll'), $_('Fast Forward')]}
					functions={[
						() => (deletePollModalShow = true),
						async () => (phase = await nextPhase(poll.poll_type, $page.params.pollId, phase))
					]}
					Class="text-black justify-self-center mt-2"
				/>
			</div>
		</div>

		<div class="flex gap-4 my-2 items-center">
			<!-- Poll Type Icons -->
			{#if poll.poll_type === 4}
				<HeaderIcon Class="!p-0 !cursor-default" icon={faAlignLeft} text={'Text Poll'} />
			{:else if poll.poll_type === 3}
				<HeaderIcon Class="!p-0 !cursor-default" icon={faCalendarAlt} text={'Date Poll'} />
			{/if}

			<!-- Fast Forward Icon -->
			{#if poll.allow_fast_forward}
				<HeaderIcon Class="!p-0 !cursor-default" icon={faAnglesRight} text={'Fast Forward'} />
			{:else}
				<div class="relative w-4 h-4">
					<Fa style="position:absolute" icon={faAnglesRight} />

					<Fa style="position:absolute" icon={faSlash} rotate="90" />
				</div>
			{/if}

			<!-- Comment icon. When user clicks it leads to the comment section on the poll -->
			<a
				class="flex gap-1 items-center text-black dark:text-darkmodeText hover:bg-gray-100 dark:hover:bg-slate-500 cursor-pointer text-sm"
				href={onHoverGroup
					? '/groups/1'
					: `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}?section=comments`}
			>
				<img class="w-5" src={ChatIcon} alt="open chat" />
				<span class="inline">{poll.total_comments}</span>
			</a>

			<!-- Tag -->
			{#if poll.poll_type === 4}
				<Tag tag={{ name: poll.tag_name, id: poll.tag_id, active: true, imac: 0 }} />
			{/if}

			<!-- Phase -->
			<div class="text-sm font-semibold text-primary dark:text-secondary">
				{$_('Current phase:')}
				{$_(getPhaseUserFriendlyName(phase))}
			</div>
		</div>

		{#if poll.description.length > 0}
			<Description limit={500} description={poll.description} Class="mt-2" />
		{/if}

		<TimelineLegacy Class="mt-2" displayDetails={false} pollType={poll.poll_type} bind:dates />

		<div class="!mt-4">
			<!-- PHASE 1: AREA VOTE -->
			{#if phase === 'area_vote'}
				<form
					on:submit|preventDefault={() => submitTagVote(selectedTag)}
					class="flex justify-between"
				>
					<Select
						label={''}
						labels={tags.map((tag) => tag.name)}
						bind:value={selectedTag}
						values={tags.map((tag) => tag.id)}
						Class="w-[47%] "
						classInner="w-full !p-2 bg-white p-4 border-gray-400 rounded-md border-2"
						onInput={() => (voting = true)}
					/>
					{#if voting}
						<Button type="submit" Class="w-[47%]" buttonStyle="primary-light"
							>{$_('Save Vote')}</Button
						>
					{:else}
						<p class="w-[47%] text-center">{$_('Successfully saved voting!')}</p>
					{/if}
				</form>

				<!-- PHASE 2: PROPOSAL CREATION -->
			{:else if phase === 'proposal'}
				<div class="flex justify-between">
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						action={() =>
							goto(`/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}?display=0`)}
						>{$_('See Proposals')} ({poll.total_proposals})</Button
					>
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						action={() =>
							goto(`/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}?display=1`)}
						>{$_('Create a Proposal')}</Button
					>
				</div>

				<!-- PHASE 3: PREDICTION STATEMENT CREATION -->
			{:else if phase === 'prediction_statement'}
				<div class="flex justify-between">
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						action={() =>
							goto(`/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}?display=0`)}
						>{$_('See Predictions')} ({poll.total_predictions})</Button
					>
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						action={() =>
							goto(`/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}?display=1`)}
						>{$_('Create a Prediction')}</Button
					>
				</div>

				<!-- PHASE 4: PREDICTION BETTING -->
			{:else if phase === 'prediction_bet'}
				<div class="flex justify-between">
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						action={() => goto(`/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`)}
						>{$_('Manage bets')}</Button
					>
					<!-- <p class="w-[47%]">{$_('You have not betted yet!')}</p> -->
				</div>

				<!-- PHASE 5 & 6: VOTING -->
			{:else if phase === 'delegate_vote' || phase === 'vote'}
				<div class="flex justify-between">
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						action={() => goto(`/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`)}
						>{$_('Manage votes')}</Button
					>
					<!-- <p class="w-[47%]">{$_('You have not voted yet!')}</p> -->
				</div>

				<!-- PHASE 7: RESULTS -->
			{:else if phase === 'prediction_vote' || phase === 'result'}
				<div class="flex justify-between">
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						action={() => goto(`/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`)}
						>{$_('View detailed results')}</Button
					>
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						action={() => goto(`/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`)}
						>{$_('Evaluate predictions')}</Button
					>
				</div>
			{/if}
		</div>
	</div>
</div>

<DeletePollModal bind:deletePollModalShow pollId={poll.id} />

<Poppup bind:poppup />

<style>
	.poll-thumbnail-shadow {
		box-shadow: 0 0 5px rgb(203, 203, 203);
	}

	.poll-thumbnail-shadow-dark {
		box-shadow: 0 0 10px rgb(24, 24, 24);
	}
</style>

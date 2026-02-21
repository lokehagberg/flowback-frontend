<script lang="ts">
	import type { Phase, poll } from './interface';
	import { page } from '$app/state';
	import Tag from '$lib/Group/Tag.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import Fa from 'svelte-fa';
	import { fetchRequest } from '$lib/FetchRequest';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';
	import {
		getPhase,
		getPhaseUserFriendlyNameWithNumber,
		imacFormatting
	} from './functions';
	import { getPermissionsFast } from '$lib/Generic/GenericFunctions';
	import Select from '$lib/Generic/Select.svelte';
	import { getTags } from '$lib/Group/functions';
	import type { Tag as TagType } from '$lib/Group/interface';
	import Button from '$lib/Generic/Button.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import {
		faAnglesRight,
		faAlignLeft,
		faCalendarAlt,
		faSlash,
		faGlobe,
		faLock
	} from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import Timeline from './NewDesign/Timeline.svelte';
	import ReportPostModal from './ReportPostModal.svelte';
	import type { Permissions } from '$lib/Group/Permissions/interface';
	import DeletePostModal from './DeletePostModal.svelte';
	import PostThumbnail from '$lib/Generic/PostThumbnail.svelte';
	import { env } from '$env/dynamic/public';

	let { poll }: { poll: poll } = $props();

	let onHoverGroup = $state(false),
		phase: Phase = $state('pre_start'),
		// If text poll, have all phases. Date polls have fewer phases to display
		dates: Date[] = $state([]),
		tags: TagType[] = $state([]),
		tag: TagType = $state({ active: false, id: 0, name: '', imac: 0 }),
		selectedTag: number = $state(0),
		voting = $state(true),
		choicesOpen = $state(false),
		deletePollModalShow = $state(false),
		reportPollModalShow = $state(false),
		hovering = $state(false),
		permissions: Permissions | null = $state(null);

	//When adminn presses the pin tack symbol, pin the poll
	const pinPoll = async () => {
		const { json, res } = await fetchRequest(
			'POST',
			`group/poll/${poll?.id}/update`,
			{
				pinned: !poll?.pinned
			}
		);

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Could not pin poll', success: false });
			return;
		}

		poll.pinned = !poll?.pinned;
		poll = { ...poll };
	};

	const submitTagVote = async (tag: number) => {
		const { json, res } = await fetchRequest(
			'POST',
			`group/poll/${poll?.id}/area/update`,
			{
				tag,
				vote: true
			}
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Could not submit tag vote',
				success: false
			});
			return;
		}

		voting = false;
	};

	const getAreaVote = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/poll/${poll?.id}/area/list`
		);

		if (!res.ok) return;

		let selectedTagName = json?.results.find(
			(tag: Tag) => tag.user_vote === true
		)?.tags[0].tag_name;

		if (selectedTagName) {
			selectedTag = tags?.find((tag) => tag.name === selectedTagName)?.id || 0;
			voting = false;
		}
	};

	const getTag = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${poll.group_id}/tags?id=${poll.tag_id}`
		);

		if (!res.ok) return;

		tag = json.results[0];
	};

	onMount(async () => {
		phase = getPhase(poll);
		if (phase === 'area_vote') {
			tags = await getTags(poll?.group_id);
			getAreaVote();
		}
		getTag();

		permissions = await getPermissionsFast(Number(poll.group_id));
	});

	$effect(() => {
		if (poll)
			dates =
				poll?.poll_type === 4
					? [
							new Date(poll?.start_date),
							new Date(poll?.area_vote_end_date),
							new Date(poll?.proposal_end_date),
							new Date(poll?.prediction_statement_end_date),
							new Date(poll?.prediction_bet_end_date),
							new Date(poll?.delegate_vote_end_date),
							new Date(poll?.end_date)
						]
					: [new Date(poll?.start_date), new Date(poll?.end_date)];
	});
</script>

<PostThumbnail post={poll} api="poll">
	{#snippet icons()}
		<div class="flex gap-4 my-2 items-center">
			<!-- Poll Type Icons -->
			{#if poll?.poll_type === 4}
				<HeaderIcon
					Class="!p-0 !cursor-default"
					icon={faAlignLeft}
					text={'Text Poll'}
				/>
			{:else if poll?.poll_type === 3}
				<HeaderIcon
					Class="!p-0 !cursor-default"
					icon={faCalendarAlt}
					text={'Date Poll'}
				/>
			{/if}

			{#if poll.public}
				<HeaderIcon
					Class="!p-0 !cursor-default"
					icon={faGlobe}
					text={'Public Poll'}
				/>
			{:else}
				<HeaderIcon
					Class="!p-0 !cursor-default"
					icon={faLock}
					text={'Private Poll'}
				/>
			{/if}

			<!-- Fast Forward Icon -->
			{#if poll?.allow_fast_forward}
				<HeaderIcon
					Class="!p-0 !cursor-default"
					icon={faAnglesRight}
					text={'Fast Forward'}
				/>
			{:else}
				<div
					role="button"
					tabindex="0"
					onmouseover={() => (hovering = true)}
					onmouseleave={() => (hovering = false)}
					onfocus={() => (hovering = true)}
					onblur={() => (hovering = false)}
					class="relative w-4 h-4"
				>
					<Fa style="position:absolute" icon={faAnglesRight} />
					<Fa style="position:absolute" icon={faSlash} rotate="90" />
					<div
						class="absolute text-black p-1 bg-white mt-4 border border-gray-400 rounded text-sm z-50 w-[100px] left-[calc(50%-50px)] text-center filter opacity-80"
						class:invisible={!hovering}
					>
						{$_('No Fast Forward')}
					</div>
				</div>
			{/if}

			<!-- Poll tag -->
			{#if poll?.poll_type === 4 && tag.name !== '' && env.PUBLIC_POLL_VERSION === '1'}
				<Tag Class="cursor-default" bind:tag />
			{/if}

			{#if poll?.interval_mean_absolute_correctness}
				{$_('Historical imac value')}: {imacFormatting(
					poll.interval_mean_absolute_correctness
				)}
			{/if}

			<!-- Phase -->
			<div class="text-sm font-semibold text-primary dark:text-secondary">
				{$_('Current phase')}
				{$_(getPhaseUserFriendlyNameWithNumber(phase, poll.poll_type))}
			</div>
		</div>
	{/snippet}

	<Timeline
		bind:phase
		bind:poll
		enableDetails
		displayTimelinePhase={false}
		Class={'w-full md:!relative'}
		horizontal
	/>

	<div class="!mt-4">
		<!-- For text polls -->
		{#if poll?.poll_type === 4 && poll?.group_joined}
			<!-- PHASE 1: AREA VOTE -->
			{#if phase === 'area_vote'}
				<form
					onsubmit={(e) => {
						e.preventDefault();
						submitTagVote(selectedTag);
					}}
					class="flex justify-between"
				>
					<Select
						label={''}
						labels={tags?.map((tag) => tag.name)}
						bind:value={selectedTag}
						values={tags?.map((tag) => tag.id)}
						Class="w-[47%] "
						classInner="w-full !p-2 bg-white p-4 border-gray-400 rounded-md border"
						onInput={() => (voting = true)}
					/>
					{#if voting}
						<Button type="submit" Class="w-[47%]" buttonStyle="primary-light"
							>{$_('Save Vote')}</Button
						>
					{:else}
						<p class="w-[47%] text-center">
							{$_('Successfully saved voting!')}
						</p>
					{/if}
				</form>

				<!-- PHASE 2: PROPOSAL CREATION -->
			{:else if phase === 'proposal'}
				<div class="flex justify-between">
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						onClick={() =>
							goto(
								`/groups/${poll?.group_id || page.params.groupId}/polls/${poll?.id}?display=0&source=${
									page.params.groupId ? 'group' : 'home'
								}`
							)}>{$_('See Proposals')} ({poll?.total_proposals})</Button
					>
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						onClick={() =>
							goto(
								`/groups/${poll?.group_id || page.params.groupId}/polls/${poll?.id}?display=1&source=${
									page.params.groupId ? 'group' : 'home'
								}`
							)}>{$_('Create a Proposal')}</Button
					>
				</div>

				<!-- PHASE 3: PREDICTION STATEMENT CREATION -->
			{:else if phase === 'prediction_statement'}
				<div class="flex justify-between">
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						onClick={() =>
							goto(
								`/groups/${poll?.group_id || page.params.groupId}/polls/${poll?.id}?display=0&source=${
									page.params.groupId ? 'group' : 'home'
								}`
							)}>{$_('See Consequences')} ({poll?.total_predictions})</Button
					>
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						onClick={() =>
							goto(
								`/groups/${poll?.group_id || page.params.groupId}/polls/${poll?.id}?display=1&source=${
									page.params.groupId ? 'group' : 'home'
								}`
							)}>{$_('Create a Consequence')}</Button
					>
				</div>

				<!-- PHASE 4: PREDICTION BETTING -->
			{:else if phase === 'prediction_bet'}
				<div class="flex justify-between">
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						onClick={() =>
							goto(
								`/groups/${poll?.group_id || page.params.groupId}/polls/${poll?.id}?source=${
									page.params.groupId ? 'group' : 'home'
								}`
							)}>{$_('Manage Probabilities')}</Button
					>
					<!-- <p class="w-[47%]">{$_('You have not betted yet!')}</p> -->
				</div>

				<!-- PHASE 5 & 6: VOTING -->
			{:else if phase === 'delegate_vote' || phase === 'vote'}
				<div class="flex justify-between">
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						onClick={() =>
							goto(
								`/groups/${poll?.group_id || page.params.groupId}/polls/${poll?.id}?source=${
									page.params.groupId ? 'group' : 'home'
								}`
							)}>{$_('Manage votes')}</Button
					>
					<!-- <p class="w-[47%]">{$_('You have not voted yet!')}</p> -->
				</div>

				<!-- PHASE 7: RESULTS AND EVALUATION -->
			{:else if phase === 'prediction_vote' || phase === 'result'}
				<div class="flex justify-between">
					<Button
						Class="w-[47%]"
						buttonStyle="primary-light"
						onClick={() =>
							goto(
								`/groups/${poll?.group_id || page.params.groupId}/polls/${poll?.id}?source=${
									page.params.groupId ? 'group' : 'home'
								}`
							)}>{$_('View results & evaluate consequences')}</Button
					>
				</div>
			{/if}
		{/if}
	</div>
</PostThumbnail>

<DeletePostModal bind:deleteModalShow={deletePollModalShow} postId={poll?.id} />

<ReportPostModal
	post_type="poll"
	group_id={poll.group_id}
	post_id={poll.id}
	post_title={poll.title}
	post_description={poll.description}
	bind:reportModalShow={reportPollModalShow}
/>

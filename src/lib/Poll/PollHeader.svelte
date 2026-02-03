<script lang="ts">
	import type { Phase, poll } from './interface';
	import { page } from '$app/stores';
	import Tag from '$lib/Group/Tag.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import { faAlignLeft } from '@fortawesome/free-solid-svg-icons/faAlignLeft';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import { env } from '$env/dynamic/public';
	import Fa from 'svelte-fa';
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import {
		getPhaseUserFriendlyName,
		imacFormatting,
		nextPhase
	} from './functions';
	import { _ } from 'svelte-i18n';
	import NewDescription from './NewDescription.svelte';
	import MultipleChoices from '$lib/Generic/MultipleChoices.svelte';
	import ReportPostModal from './ReportPostModal.svelte';
	import {
		groupUserStore,
		groupUserPermissionStore
	} from '$lib/Group/interface';
	import DeletePostModal from './DeletePostModal.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Tag as TagType } from '$lib/Group/interface';
	import { onMount } from 'svelte';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { isMobile } from '$lib/utils/isMobile';

	export let poll: poll,
		displayTag = false,
		phase: Phase,
		pollType: 3 | 4 = 3;

	let deletePollModalShow = false,
		reportPollModalShow = false,
		choicesOpen = false,
		source = new URLSearchParams(window.location.search).get('source'),
		tag: TagType;

	const getTag = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${poll.group_id}/tags?id=${poll.tag_id}`
		);

		if (!res.ok) return;

		tag = json.results[0];
	};

	onMount(() => {
		getTag();
	});

	$: pictureSize = $isMobile ? 2 : 1;
	$: poll && getTag();
</script>

<div
	class="bg-white dark:bg-darkobject dark:text-darkmodeText rounded shadow poll-header-grid py-8 w-full max-w-[1200px]"
>
	<button
		class="cursor-pointer bg-white dark:bg-darkobject dark:text-darkmodeText justify-center m-0 px-4"
		on:click={() => {
			if (source === 'home') goto('/home');
			else if (source === 'group')
				goto(`/groups/${$page.params.groupId}?page=flow`);
			else if (
				source === 'delegate-history' ||
				source === 'notification' ||
				source === 'create'
			)
				history.back();
		}}
	>
		<!-- NOTE: In +layout, rote folder, there are URL related behaviours which are affected by this. -->
		<Fa icon={faArrowLeft} />
	</button>

	<h1
		class="text-left text-2xl text-primary dark:text-secondary font-semibold break-words"
	>
		{poll?.title}
	</h1>

	<div class="inline-flex gap-4 items-baseline">
		<NotificationOptions
			type="poll"
			id={poll?.id}
			api={`group/poll/${poll?.id}/subscribe`}
			categories={['poll', 'poll_comment', 'poll_phase']}
			labels={['Poll', 'Timeline', 'Comments']}
			Class="justify-self-center mt-2"
			ClassOpen="right-0"
		/>

		<MultipleChoices
			bind:choicesOpen
			labels={phase !== 'result' &&
			phase !== 'prediction_vote' &&
			poll?.allow_fast_forward &&
			($groupUserPermissionStore?.poll_fast_forward ||
				$groupUserStore?.is_admin)
				? [$_('Delete Poll'), $_('Report Poll'), $_('Fast Forward')]
				: [$_('Delete Poll'), $_('Report Poll')]}
			functions={[
				() => ((deletePollModalShow = true), (choicesOpen = false)),
				() => ((reportPollModalShow = true), (choicesOpen = false)),
				...($groupUserStore?.is_admin
					? [async () => (phase = await nextPhase(poll, phase))]
					: [])
			]}
			ClassInner="-translate-x-3/4"
			id="poll-header-multiple-choices"
		/>
	</div>

	<div class="flex gap-4 items-center grid-area-items my-1 border-b py-4">
		{#if env.PUBLIC_ONE_GROUP_FLOWBACK !== 'TRUE'}
			<a
				href={`/groups/${$page.params.groupId}`}
				class:hover:underline={poll?.group_joined}
				class="text-black dark:text-darkmodeText"
			>
				<ProfilePicture
					Class={!$isMobile ? '' : 'w-10 h-10'}
					displayName={!$isMobile}
					profilePicture={poll?.group_image}
					username={poll?.group_name}
					type="group"
					size={pictureSize}
				/>
			</a>

			<div class="text-xs sm:text-base">
				{#if $groupUserPermissionStore?.allow_vote}
					{$_('You are allowed to vote')}
				{:else}
					{$_('You are not allowed to vote')}
				{/if}
			</div>

			{#if pollType === 4}
				<div>
					{$_('Current phase')}:
					{$_(getPhaseUserFriendlyName(phase))}
				</div>
			{/if}

			{#if poll?.work_group_id}
				{$_('Workgroup')}: {poll.work_group_name}
			{/if}

			{#if poll?.interval_mean_absolute_correctness}
				{$_('Historical imac value')}: {imacFormatting(
					poll.interval_mean_absolute_correctness
				)}
			{/if}

			{#if poll?.poll_type === 4}
				<HeaderIcon
					Class="cursor-default"
					icon={faAlignLeft}
					text={'Text Poll'}
				/>
			{:else if poll?.poll_type === 3}
				<HeaderIcon
					Class="cursor-default"
					icon={faCalendarAlt}
					text={'Date Poll'}
				/>
			{/if}

			{#if displayTag && tag}
				<Tag id={'poll-tag'} bind:tag />
			{/if}
		{/if}
	</div>

	{#if poll?.description.length > 0}
		<div class="grid-area-description break-words w-[90vw] max-w-[1100px] mt-4">
			<NewDescription
				limit={3}
				lengthLimit={300}
				description={poll?.description}
			/>
		</div>
	{/if}
</div>

{#if poll?.attachments && poll?.attachments.length > 0}
	<div>
		<div class="grid-area-attachments">
			{#each poll?.attachments as attachment}
				<div class="attachment-item">
					<a
						href={`${env.PUBLIC_API_URL}/media/${attachment.file}`}
						download
						target="_blank"
						rel="noopener noreferrer"
						class="download-link text-blue-600 hover:underline"
					>
						{`${env.PUBLIC_API_URL}/media/${attachment.file}`}
					</a>
				</div>
			{/each}
		</div>
	</div>
{/if}

<DeletePostModal
	bind:deleteModalShow={deletePollModalShow}
	postId={$page.params.pollId ?? ''}
/>

<ReportPostModal
	post_type="poll"
	group_id={poll.group_id}
	post_id={poll.id}
	post_title={poll.title || ''}
	post_description={poll.description || ''}
	bind:reportModalShow={reportPollModalShow}
/>

<style>
	.poll-header-grid {
		display: grid;
		grid-template-columns: 0.3fr 4fr 0.3fr;
	}

	.grid-area-items {
		grid-area: 2 / 2 / 3 / 3;
	}

	.grid-area-description {
		grid-area: 3 / 2 / 4 / 3;
	}

	@media (max-width: 768px) {
		.poll-header-grid {
			max-width: 100vw;
		}

		.grid-area-description {
			width: 100%;
			word-break: break-word;
		}
	}
</style>

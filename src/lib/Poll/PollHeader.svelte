<script lang="ts">
	import type { Phase, poll } from './interface';
	import { page } from '$app/stores';
	import Tag from '$lib/Group/Tag.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import { faAlignLeft } from '@fortawesome/free-solid-svg-icons/faAlignLeft';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import { onThumbnailError } from '$lib/Generic/GenericFunctions';
	import DefaultBanner from '$lib/assets/default_banner_group.png';
	import { env } from '$env/dynamic/public';
	import Fa from 'svelte-fa';
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import { getPhaseUserFriendlyName, nextPhase } from './functions';
	import { _ } from 'svelte-i18n';
	import Description from './Description.svelte';
	import MultipleChoices from '$lib/Generic/MultipleChoices.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import DeletePollModal from './DeletePollModal.svelte';

	export let poll: poll,
		displayTag = false,
		phase: Phase,
		pollType: 3 | 4 = 3;

	let deletePollModalShow = false,
		poppup: poppup;
</script>

<div
	class="bg-white dark:bg-darkobject dark:text-darkmodeText rounded shadow w-full poll-header-grid"
>
	<button
		class="cursor-pointer bg-white dark:bg-darkobject dark:text-darkmodeText justify-center m-auto"
		on:click={() => goto(`/groups/${$page.params.groupId}`)}
	>
		<!-- NOTE: In +layout, rote folder, there are URL related behaviours which are affected by this. -->
		<Fa icon={faArrowLeft} />
	</button>
	<h1 class="text-left text-2xl text-primary font-semibold break-all">{poll.title}</h1>
	<!-- <HeaderIcon Class="p-2 cursor-default" icon={faHourglass} text={'End date'} /> -->

	<div class="flex gap-3 justify-center m-auto">
		<NotificationOptions
			id={poll.id}
			api={`group/poll/${poll.id}`}
			categories={['poll', 'timeline', 'comment_all']}
			labels={['Poll', 'Timeline', 'Comments']}
			Class="justify-self-center mt-2"
			ClassOpen="right-0"
		/>
		<!-- {#if groupUser?.is_admin} -->
		<MultipleChoices
			labels={phase === 'result' || phase === 'prediction_vote'
				? [$_('Delete Poll')]
				: [$_('Delete Poll'), $_('Fast Forward')]}
			functions={[
				() => (deletePollModalShow = true),
				async () => (phase = await nextPhase(pollType, $page.params.pollId, phase))
			]}
			Class="justify-self-center mt-2"
		/>
		<!-- {/if} -->
	</div>

	<div class="flex gap-4 items-baseline grid-area-items mt-1">
		{#if poll.poll_type === 4}
			<!-- TODO make it easy to change poll types e.t.c -->
			<HeaderIcon Class="cursor-default" icon={faAlignLeft} text={'Text Poll'} />
		{:else if poll.poll_type === 3}
			<HeaderIcon Class="cursor-default" icon={faCalendarAlt} text={'Date Poll'} />
		{/if}
		<!-- Group Profile -->
		{#if displayTag}
			<Tag Class="w-32" tag={{ name: poll.tag_name, id: poll.tag_id, active: true, imac: 0 }} />
		{/if}
		{#if env.PUBLIC_ONE_GROUP_FLOWBACK !== 'TRUE'}
			<a
				href={`/groups/${$page.params.groupId}`}
				class:hover:underline={poll.group_joined}
				class="text-black dark:text-darkmodeText"
			>
				<img
					class="h-8 w-8 inline rounded-full"
					src={`${env.PUBLIC_API_URL}${poll.group_image}`}
					alt="group thumbnail"
					on:error={(e) => onThumbnailError(e, DefaultBanner)}
				/>
				<span class="inline">{poll.group_name}</span>
			</a>
			<!-- Current Phase -->
			<div>
				{$_('Current phase:')}
				{$_(getPhaseUserFriendlyName(phase))}
			</div>
		{/if}
	</div>

	{#if poll.description.length > 0}
		<div class="grid-area-description break-all">
			<Description limit={400} description={poll.description} />
		</div>
	{/if}

	<!-- TODO: fix attachments in poll -->
	<!-- {#if poll.attachments && poll.attachments.length > 0}
		<img
			src={`${env.PUBLIC_API}/api/media/${poll.attachments[0].file}` || ''}
			alt="attachment to the poll"
		/>
	{/if} -->
</div>

<DeletePollModal bind:deletePollModalShow pollId={$page.params.groupId} />

<Poppup bind:poppup />

<style>
	.poll-header-grid {
		display: grid;
		grid-template-columns: 0.3fr 4fr 0.3fr;
		/* grid-template-rows: 0.1fr 0.2fr 1fr; */
	}

	.grid-area-items {
		grid-area: 2 / 2 / 3 / 3;
	}

	.grid-area-description {
		grid-area: 3 / 2 / 4 / 3;
	}
</style>

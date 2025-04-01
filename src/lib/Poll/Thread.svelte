<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import ChatIcon from '$lib/assets/Chat_fill.svg';
	import { goto } from '$app/navigation';
	import type { poppup } from '$lib/Generic/Poppup';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import Fa from 'svelte-fa';
	import { faThumbTack, faThumbsUp, faThumbsDown } from '@fortawesome/free-solid-svg-icons';
	import { _ } from 'svelte-i18n';
	import Description from '$lib/Poll/Description.svelte';
	import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';
	import type { Thread } from '$lib/Group/interface';
	import MultipleChoices from '$lib/Generic/MultipleChoices.svelte';
	import { onMount } from 'svelte';

	export let isAdmin = true,
		thread: Thread;

	let threads: Thread[] = [],
		poppup: poppup;

	//Launches whenever the user clicks upvote or downvote on a thread
	const threadVote = async (_thread: Thread, clicked: 'down' | 'up') => {
		let vote: null | false | true = null;

		// TODO: There's gotta be a more elegant way to do this
		if (_thread?.user_vote === null && clicked === 'up') {
			vote = true;
			thread.score++;
		} else if (_thread?.user_vote === null && clicked === 'down') {
			vote = false;
			thread.score--;
		} else if (_thread?.user_vote === false && clicked === 'up') {
			vote = true;
			thread.score += 2;
		} else if (_thread?.user_vote === false && clicked === 'down') {
			vote = null;
			thread.score++;
		} else if (_thread?.user_vote === true && clicked === 'up') {
			vote = null;
			thread.score--;
		} else if (_thread?.user_vote === true && clicked === 'down') {
			vote = false;
			thread.score -= 2;
		}

		const { res, json } = await fetchRequest('POST', `group/thread/${_thread?.id}/vote`, { vote });

		if (!res.ok) {
			poppup = { message: 'Could not vote on thread', success: false };
			return;
		}

		thread.user_vote = vote;

		//TODO: Make this more efficient by not having to reload threads.
		// getThreads();
	};

	//When adminn presses the pin tack symbol, pin the thread
	const pinThread = async (thread: Thread) => {
		const { json, res } = await fetchRequest('POST', `group/thread/${thread?.id}/update`, {
			pinned: !thread?.pinned
		});
		if (!res.ok) return;

		thread.pinned = !thread?.pinned;
		threads = threads;
	};
</script>

<div
	class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 shadow-[0_0_5px_rgb(203,203,203)] rounded-md"
>
	<div class="flex justify-between items-center">
		<a
			class="break-all cursor-pointer hover:underline text-primary dark:text-secondary text-2xl text-left"
			href={`groups/${thread?.created_by?.group_id}/thread/${thread?.id}`}>{thread?.title}</a
		>
		<div class=" inline-flex gap-4 items-baseline">
			<NotificationOptions
				type="group_thread"
				api={`group/thread/${thread?.id}`}
				categories={['comment']}
				id={thread?.id}
				labels={['comment']}
			/>
			{#if isAdmin || thread?.pinned}
				<button class:cursor-pointer={isAdmin} on:click={() => pinThread(thread)}>
					<Fa
						size="1.2x"
						icon={faThumbTack}
						color={thread?.pinned ? '#999' : '#CCC'}
						rotate={thread?.pinned ? '0' : '45'}
					/>
				</button>
			{/if}

			<MultipleChoices
				labels={[$_('Delete Thread')]}
				functions={[]}
				Class="text-black justify-self-center"
			/>
		</div>
	</div>

	{#if thread?.work_group}
		<span class="text-sm text-gray-500 dark:text-darkmodeText">#{thread.work_group.name}, </span>
	{/if}
	{#if thread?.created_at}
		<span class="text-sm text-gray-500 dark:text-darkmodeText">
			{new Date(thread.created_at).toISOString().split('T')[0].replace(/-/g, '.')}
		</span>
	{/if}
	{#if thread?.description}
		<Description limit={500} description={thread?.description} />
	{/if}

	<hr class="my-3" />

	<div class="flex justify-between align-middle">
		<div
			class="hover:bg-gray-100 dark:hover:bg-slate-500 cursor-pointer text-sm text-gray-600 dark:text-darkmodeText"
		>
			<a
				class="text-black dark:text-darkmodeText flex justify-center gap-1"
				href={`${thread?.created_by?.group_id}/thread/${thread?.id}`}
			>
				<img class="w-5" src={ChatIcon} alt="open chat" />
				<span class="inline">{thread?.total_comments} {'comments'}</span>
			</a>
		</div>
		<div>
			<div class="flex items-center gap-2">
				<button
					class:text-primary={thread?.user_vote === true}
					on:click={() => threadVote(thread, 'up')}
				>
					<Fa icon={faThumbsUp} />
				</button>
				{thread?.score}
				<button
					class:text-primary={thread?.user_vote === false}
					on:click={() => threadVote(thread, 'down')}
				>
					<Fa class="pl-0.5" icon={faThumbsDown} />
				</button>
			</div>
		</div>
	</div>
</div>

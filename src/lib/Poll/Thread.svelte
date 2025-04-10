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
	import NewDescription from '$lib/Poll/NewDescription.svelte';
	import type { WorkGroup } from '$lib/Group/WorkingGroups/interface';
	import type { Thread } from '$lib/Group/interface';
	import MultipleChoices from '$lib/Generic/MultipleChoices.svelte';
	import { onMount } from 'svelte';
	import { reportThread } from './functions';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import { faSpinner} from '@fortawesome/free-solid-svg-icons';
	export let isAdmin = true,

		thread: Thread;
	let threads: Thread[] = [],
		poppup: poppup,
		reportReason = '';
	
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
	let threadIsBeingReported = false;
	let reporting = false
</script>

<div
	class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 shadow-[0_0_5px_rgb(203,203,203)] rounded-md"
>
	<div class="flex justify-between items-center">
		<a
			class="break-words cursor-pointer hover:underline text-primary dark:text-secondary text-xl text-left"
			href={`/groups/${thread?.created_by?.group_id}/thread/${thread?.id}`}>{thread?.title}</a
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
				labels={[$_('Delete Thread'), $_('Report Thread')]}
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
		<NewDescription limit={2} lengthLimit={700} description={thread?.description} />
	{/if}

	<hr class="my-3" />

	<div class="flex justify-between align-middle">
		<div
			class="hover:bg-gray-100 dark:hover:bg-slate-500 cursor-pointer text-sm text-gray-600 dark:text-darkmodeText"
		>
			<a
				class="text-black dark:text-darkmodeText flex justify-center gap-1"
				href={`groups/${thread?.created_by?.group_id}/thread/${thread?.id}`}
			>
				<img class="w-5" src={ChatIcon} alt="open chat" />
				<span class="inline">{thread?.total_comments} {'comments'}</span>
			</a>
		</div>
		<div>
			<div class="flex items-center gap-2">
				{#if thread?.created_by.id !== Number(localStorage.getItem('userId'))}
					<button class=' text-red-500 hover:textred-50 mr-3 ' on:click={()=> threadIsBeingReported = true}>
						Report
					</button>
				{/if}
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
	{#if threadIsBeingReported}
    <Modal bind:open={threadIsBeingReported} Class="min-w-[500px] md:w-[700px]">
        <div slot="header">{$_('Report Thread')}</div>
        <div slot="body" class="px-6">
            <form on:submit|preventDefault={async () => {
				reporting = true;
                const result = await reportThread(thread.id, reportReason);
                poppup = { message: result?.message, success: result.success };
                threadIsBeingReported = false;
                reportReason = '';
				reporting = false;
            }}>
                <p class="text-lg mb-4">{$_(`Are you sure you want to report this thread?`)}</p>
                <TextArea 
                    label={$_('Reason for reporting')} 
                    bind:value={reportReason} 
                    required 
                    rows={4}
                    Class="w-full"
                />
                <div class="flex justify-end gap-2 mt-4">
                    <Button 
                        buttonStyle="warning-light" 
                        onClick={() => {
                            threadIsBeingReported = false;
                            reportReason = '';
                        }}
                    >
                        {$_('Cancel')}
                    </Button>
                    <Button Class="flex items-center gap-2"  type="submit" disabled={reporting}>
                        {$_(reporting ? 'Submitting...' : 'Report')}
						{#if reporting}
							<Fa icon={faSpinner} spin={reporting}/> 
						{/if}
                    </Button>
                </div>
            </form>
        </div>
    </Modal>
{/if}
</div>
<Poppup bind:poppup />
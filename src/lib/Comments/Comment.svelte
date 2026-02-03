<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Comment, proposal } from '$lib/Poll/interface';
	import { faThumbsUp, faThumbsDown } from '@fortawesome/free-solid-svg-icons';
	import { userStore } from '$lib/User/interfaces';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import CommentPost from './CommentPost.svelte';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { onMount } from 'svelte';
	import { env } from '$env/dynamic/public';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import Modal from '$lib/Generic/Modal.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { commentsStore } from './commentStore';

	export let comment: Comment,
		api: 'poll' | 'thread' | 'delegate-history',
		proposals: proposal[] = [], // Give it a default empty array
		delegate_pool_id: number | null = null;

	let userUpVote: -1 | 0 | 1 = 0,
		comments: Comment[],
		isVoting = false,
		ReportCommentModalShow = false,
		reportTitle: string,
		reportDescription: string,
		images: File[] = [];

	const commentDelete = async (id: number) => {
		let _api = `group/`;

		if (api === 'poll') _api += `poll/${$page.params.pollId}/`;
		else if (api === 'thread') _api += `thread/${$page.params.threadId}/`;
		else if (api === 'delegate-history') _api += `delegate/pool/${delegate_pool_id}/`;

		_api += `comment/${id}/delete`;

		const { res, json } = await fetchRequest('POST', _api);

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Failed to delete comment', success: false });
			return;
		}

		comments?.map((comment) => {
			if (comment.id !== id) return comment;

			comment.message = '[Deleted]';
			comment.active = false;
			return comment;
		});
		comments = comments;
	};

	const commentReport = async (id: number, message: string) => {
		let _api = 'report/create';

		let data = {
			title: reportTitle,
			description: reportDescription
		};

		const { res, json } = await fetchRequest('POST', _api, data);

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Failed to report comment', success: false });
			return;
		}

		comments.map((comment) => {
			if (comment.id !== id) return comment;

			// comment.message = '[Reported]';
			comment.active = false;
			comment.being_reported = true;
			return comment;
		});
		comments = comments;
	};

	// The entire upvote-downvote system in the front end is ugly brute-force, refactoring would be neat.
	const commentVote = async (_vote: -1 | 1) => {
		if (isVoting) return; // Prevent multiple clicks while processing
		isVoting = true;

		let vote = {};
		let regretting = userUpVote === _vote;

		if (regretting) vote = { vote: null };
		else if (_vote === -1) vote = { vote: false };
		else if (_vote === 1) vote = { vote: true };

		let _api = '';
		if (api === 'poll') _api = `group/poll/${$page.params.pollId}/comment/${comment.id}/vote`;
		else if (api === 'thread')
			_api = `group/thread/${$page.params.threadId}/comment/${comment.id}/vote`;
		else if (api === 'delegate-history')
			_api = `group/delegate/pool/${delegate_pool_id}/comment/${comment.id}/vote`;

		const { res, json } = await fetchRequest('POST', _api, vote);

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Comment vote failed', success: false });
			return;
		}

		// Only update UI after successful API call
		if (regretting) {
			userUpVote = 0;
			comment.user_vote = null;
			if (_vote === 1) comment.score -= 1;
			else if (_vote === -1) comment.score += 1;
		} else {
			if (userUpVote !== 0) {
				// If changing vote from up to down or vice versa
				comment.score += 2 * _vote;
			} else {
				comment.score += _vote;
			}
			userUpVote = _vote;
			comment.user_vote = _vote === 1;
		}

		isVoting = false;
	};

	onMount(() => {
		if (comment.user_vote === null || comment.user_vote === undefined) userUpVote = 0;
		else if (comment.user_vote === true) userUpVote = 1;
		else if (comment.user_vote === false) userUpVote = -1;

		commentsStore.subscribe((store) => {
			comments = store.allComments;
		});
	});
</script>

{#if comment.being_edited}
	<CommentPost
		{delegate_pool_id}
		bind:proposals
		bind:comments
		bind:files={images}
		bind:beingEdited={comment.being_edited}
		message={comment.message || ''}
		parent_id={comment.parent_id}
		id={comment.id}
		{api}
	/>
{:else}
	<!-- class:bg-gray-100={comment.reply_depth % 2 === 1} -->
	<!-- class:dark:bg-darkbackground={comment.reply_depth % 2 === 1} -->
	<div
		class={`p-3 text-sm border-0 border-l-gray-400  dark:text-darkmodeText`}
		style:margin-left={`${comment.reply_depth * 20}px`}
		class:border-l-2={comment.reply_depth > 0}
	>
		<div class="flex gap-2">
			<ProfilePicture
				profilePicture={comment.author_profile_image}
				username={comment.author_name}
				displayName
				userId={comment.author_id}
				Class="font-semibold"
			/>
		</div>
		{#key comment.message}
			{#if comment.message}
				<div
					class="text-md mt-1 mb-3 pl-14 break-words whitespace-pre-wrap"
					id={`comment-${comment.id}`}
				>
					{comment.message}
				</div>
			{/if}
		{/key}
		<div class="pl-14 text-xs text-gray-400 dark:text-darkmodeText">
			{comment.edited && comment.active ? $_('(edited)') : ''}
		</div>
		{#if comment.attachments?.length > 0}
			<div class="pl-14 mt-1 mb-3">
				{#each comment.attachments as attachment}
					<!-- {@debug attachment} -->
					{#if typeof attachment.file === 'string' && (attachment.file
							.slice(-3)
							.toLowerCase() === 'pdf' || attachment.file.slice(-3).toLowerCase() === 'txt')}
						<a
							href={attachment.file.substring(0, 4) === 'blob'
								? attachment.file
								: `${env.PUBLIC_API_URL}/media/${attachment.file}`}
							target="_blank"
							rel="noopener noreferrer"
							class="text-primary dark:text-secondary hover:underline"
						>
							{$_('View File')}

							<!-- {typeof attachment?.file}
							{attachment?.file} -->
						</a>
					{:else}
						<img
							src={(() => {
								if (typeof attachment.file === 'string')
									return attachment.file.substring(0, 4) === 'blob'
										? attachment.file
										: `${env.PUBLIC_API_URL}/media/${attachment.file}`;
								else return URL.createObjectURL(attachment.file);
							})()}
							alt="Attachment to the comment"
						/>
						<!-- {typeof attachment?.file}
						{attachment?.file} -->
					{/if}
				{/each}
			</div>
		{/if}

		{#if comment.active}
			<div class="flex gap-6 text-xs pl-14">
				<div class="flex items-center gap-2">
					<button
						class:text-primary={comment.user_vote === true}
						class="flex items-center gap-1 cursor-pointer transition-colors"
						on:click={() => commentVote(1)}
					>
						<Fa icon={faThumbsUp} />
					</button>
					{comment.score}
					<button
						class:text-primary={comment.user_vote === false}
						class="flex items-center gap-1 cursor-pointer transition-colors"
						on:click={() => commentVote(-1)}
					>
						<Fa class="pl-0.5" icon={faThumbsDown} />
					</button>
				</div>
				<!-- {/if} -->

				<button
					class="flex items-center gap-1 hover:text-gray-900 text-gray-600 dark:text-darkmodeText dark:hover:text-gray-400 cursor-pointer transition-colors hover:underline"
					on:click={() => (comment.being_replied = true)}
				>
					<!-- <Fa icon={faReply} /> -->
					{$_('Reply')}
				</button>
				{#if ($userStore?.id || -1) !== comment.author_id}
					<button
						class="flex items-center gap-1 hover:text-red-900 text-gray-600 dark:text-darkmodeText dark:hover:text-red-400 cursor-pointer transition-colors hover:underline"
						on:click={() => (ReportCommentModalShow = true)}
					>
						{$_('Report')}
					</button>
				{/if}

				{#if Number($userStore?.id || -1) === comment.author_id}
					<button
						class="hover:text-gray-900 text-gray-600 dark:text-darkmodeText hover:dark:text-gray-400 cursor-pointer transition-colors hover:underline"
						on:click={() => commentDelete(comment.id)}
					>
						{$_('Delete')}
					</button>
					<button
						class="hover:text-gray-900 text-gray-600 dark:text-darkmodeText hover:dark:text-gray-400 cursor-pointer transition-colors break-words hover:underline"
						on:click={() => {
							comment.being_edited = true;
							comment.being_edited_message = comment.message || '';
						}}
					>
						{$_('Edit')}
					</button>
				{/if}

				<Modal
					bind:open={ReportCommentModalShow}
					buttons={[
						{
							label: 'Report',
							type: 'warning',
							onClick: () => commentReport(comment.id, comment.message || '')
						},
						{ label: 'Cancel', type: 'secondary', onClick: () => (ReportCommentModalShow = false) }
					]}
				>
					<div slot="header">{$_('Report Comment')}</div>
					<div class="flex flex-col gap-3" slot="body">
						<TextInput inputClass="bg-white" required label="Title" bind:value={reportTitle} />
						<TextArea
							label="Description"
							required
							bind:value={reportDescription}
							inputClass="whitespace-pre-wrap"
						/>
					</div>
				</Modal>
			</div>
		{/if}
	</div>
{/if}

{#if comment.being_replied}
	<CommentPost
		{delegate_pool_id}
		bind:files={images}
		bind:proposals
		bind:comments
		bind:replying={comment.being_replied}
		parent_id={comment.id}
		{api}
	/>
{/if}

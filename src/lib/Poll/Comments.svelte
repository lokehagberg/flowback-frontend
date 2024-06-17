<script lang="ts">
	import CommentPost from './CommentPost.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { Comment } from './interface';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import { faReply } from '@fortawesome/free-solid-svg-icons/faReply';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { proposal } from './interface';
	import { checkForLinks } from '$lib/Generic/GenericFunctions';
	import { pollComments as pollCommentsLimit } from '../Generic/APILimits.json';

	let comments: Comment[] = [],
		show = false,
		showMessage = '';

	export let proposals: proposal[] = [],
		api: 'poll' | 'thread' | 'delegate-history',
		delegate_pool_id: null | number = null;

	const getComments = async () => {
		let _api = '';

		if (api === 'poll') _api += `group/poll/${$page.params.pollId}`;
		else if (api === 'thread') _api += `group/thread/${$page.params.threadId}`;
		else if (api === 'delegate-history') _api += `group/delegate/pool/${1}`;

		_api += `/comment/list?limit=${pollCommentsLimit}`;

		const { res, json } = await fetchRequest('GET', _api);

		comments = json.results.map((comment: Comment) => {
			comment.being_edited = false;
			comment.being_replied = false;
			return comment;
		});
	};

	const deleteComment = async (id: number) => {
		let _api = `group/${api}/`;

		if (api === 'poll') _api += `${$page.params.pollId}/`;
		// else if (api === 'thread') _api += `${$page.params.threadId}`;

		_api += `comment/${id}/delete`;

		const { res, json } = await fetchRequest('POST', _api);

		if (res.ok) {
			show = true;
			showMessage = 'Comment Deleted';
			let comment = comments.find((comment) => comment.id === id);
			if (comment === undefined) return;
			comment.message = '[Deleted]';
			comments = comments;
		}
	};

	const getCommentDepth = (comment: Comment): number => {
		let depth: number = 0;

		if (comment.parent_id === null) return 0;
		else {
			let parentComment = comments.find((_comment) => _comment.id === comment.parent_id);
			if (parentComment) return getCommentDepth(parentComment) + 1;
		}

		return depth;
	};

	const commentSetup = async () => {
		await getComments();
		// sortComments();
		comments.map((comment) => (comment.reply_depth = getCommentDepth(comment)));
		comments.forEach((comment) => {
			checkForLinks(comment.message, `comment-${comment.id}`);
		});
		comments = comments;
	};

	onMount(() => {
		commentSetup();
	});
</script>

<SuccessPoppup bind:show message={showMessage} />

<div
	class="p-4 border border-gray-200 dark:border-gray-500 rounded dark:text-darktext"
	id="comments"
>
	<h1 class="text-left text-2xl">{$_('Comments')}</h1>
	<!-- Add Comment -->
	<CommentPost
		bind:proposals
		bind:comments
		parent_id={undefined}
		replyDepth={-1}
		{api}
		{delegate_pool_id}
		{commentSetup}
	/>

	<div class="flex flex-col gap-4 mt-6">
		{#each comments as comment}
			{#if comment.being_edited}
				<!-- TODO: Finish comment refactoring -->
				<CommentPost
					bind:proposals
					bind:comments
					bind:beingEdited={comment.being_edited}
					message={comment.message}
					parent_id={comment.parent_id}
					replyDepth={comment.reply_depth}
					id={comment.id}
					{api}
					{delegate_pool_id}
					{commentSetup}
				/>
			{:else}
				<div
					class={`p-3 text-sm border border-l-gray-400 ml-${
						comment.reply_depth * 3
						// comment.reply_depth < 5 ? comment.reply_depth * 2 : 10
					}`}
					class:bg-gray-100={comment.reply_depth % 2 === 1}
					class:dark:bg-darkbackground={comment.reply_depth % 2 === 1}
				>
					<!-- TODO: Improve the <ProfilePicture /> component and use it here -->
					<div class="flex gap-2">
						<!-- <img class="w-6 h-6 rounded-full" src={DefaultPFP} alt="default pfp" /> -->
						<!-- <ProfilePicture user={comment}/> -->
						<div class="text-gray-700 dark:text-darkmodeText">{comment.author_name}</div>
					</div>
					<div class="text-md mt-1 mb-3 break-words" id={`comment-${comment.id}`}>
						{comment.message}
					</div>
					<div class="text-xs text-gray-400 dark:text-darkmodeText">
						{comment.edited ? '(edited)' : ''}
					</div>
					{#if comment.attachments?.length > 0}
						<div>
							{#each comment.attachments as attachment}
								<img
									class=""
									src={`${import.meta.env.VITE_API}/media/${attachment.file}`}
									alt="attachment to the comment"
								/>
							{/each}
						</div>
					{/if}
					{#if comment.active}
						<div class="flex gap-3 text-xs">
							<!-- svelte-ignore a11y-no-static-element-interactions -->
							<div
								class="flex items-center gap-1 hover:text-gray-900 text-gray-600 dark:text-darkmodeText dark:hover:text-gray-400 cursor-pointer transition-colors"
								on:click={() => (comment.being_replied = true)}
								on:keydown
							>
								<Fa icon={faReply} />{$_('Reply')}
							</div>
							{#if Number(localStorage.getItem('userId')) === comment.author_id}
								<!-- svelte-ignore a11y-no-static-element-interactions -->
								<div
									class="hover:text-gray-900 text-gray-600 dark:text-darkmodeText hover:dark:text-gray-400 cursor-pointer transition-colors"
									on:click={() => deleteComment(comment.id)}
									on:keydown
								>
									{$_('Delete')}
								</div>
								<!-- svelte-ignore a11y-no-static-element-interactions -->
								<div
									class="hover:text-gray-900 text-gray-600 dark:text-darkmodeText hover:dark:text-gray-400 cursor-pointer transition-colors break-words"
									on:click={() => {
										comment.being_edited = true;
										comment.being_edited_message = comment.message;
									}}
									on:keydown
								>
									{$_('Edit')}
								</div>
							{/if}
						</div>
					{/if}
				</div>
			{/if}
			{#if comment.being_replied}
				<CommentPost
					bind:proposals
					bind:comments
					bind:replying={comment.being_replied}
					parent_id={comment.id}
					replyDepth={comment.reply_depth}
					{api}
					{commentSetup}
				/>
			{/if}
		{/each}
	</div>
	{#if comments.length === 0}
		<div>{$_('There are currently no comments')}</div>
	{/if}
</div>

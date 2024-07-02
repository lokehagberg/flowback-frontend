<script lang="ts">
	import CommentPost from './CommentPost.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { Comment as CommentType  } from '../Poll/interface';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import type { proposal } from '../Poll/interface';
	import { checkForLinks } from '$lib/Generic/GenericFunctions';
	import { pollComments as pollCommentsLimit } from '../Generic/APILimits.json';
	import Comment from './Comment.svelte';

	export let proposals: proposal[] = [],
		api: 'poll' | 'thread' | 'delegate-history',
		delegate_pool_id: null | number = null;

	let comments: CommentType[] = [],
		show = false,
		showMessage = '';

	const getComments = async () => {
		let _api = '';

		if (api === 'poll') _api += `group/poll/${$page.params.pollId}`;
		else if (api === 'thread') _api += `group/thread/${$page.params.threadId}`;
		else if (api === 'delegate-history') _api += `group/delegate/pool/${1}`;

		_api += `/comment/list?limit=${pollCommentsLimit}`;

		const { res, json } = await fetchRequest('GET', _api);

		comments = json.results.map((comment: CommentType) => {
			comment.being_edited = false;
			comment.being_replied = false;
			return comment;
		});
	};

	const getCommentDepth = (comment: CommentType): number => {
		let depth: number = 0;

		if (comment.parent_id === null) return 0;
		else {
			let parentComment = comments.find((_comment) => _comment.id === comment.parent_id);
			if (parentComment)
				if (parentComment.reply_depth) return parentComment.reply_depth + 1;
				else return getCommentDepth(parentComment) + 1;
		}

		return depth;
	};

	const commentSetup = async () => {
		await getComments();
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
					<Comment {comment} bind:comments bind:api/>
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

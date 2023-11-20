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

	export let proposals: proposal[] = [];

	const getComments = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/comment/list?limit=${pollCommentsLimit}`
		);

		comments = json.results.map((comment: Comment) => {
			comment.being_edited = false;
			comment.being_replied = false;
			return comment;
		});
	};

	const deleteComment = async (id: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/comment/${id}/delete`
		);
		if (res.ok) {
			show = true;
			showMessage = 'Comment Deleted';
			let comment = comments.find((comment) => comment.id === id);
			if (!comment) return;
			comment.message = '[Deleted]';
			comments = comments;
		}
	};

	const sortComments = () => {
		let parentComments = comments.filter((comment) => comment.parent_id === null);
		let childrenComments = comments.filter((comment) => comment.parent_id !== null);

		let sortedComments = parentComments.map((parent) => {
			parent.reply_depth = 0;
			return parent;
		});

		while (childrenComments.length > 0) {
			childrenComments.every((child, j) => {
				parentComments.forEach((parent, i) => {
					if (parent.id === child.parent_id) {
						child.reply_depth = parent.reply_depth + 1;
						sortedComments.splice(i + 1, 0, child);
						childrenComments.splice(j, 1);
						return false;
					}
				});
			});
			parentComments = sortedComments;
		}

		comments = sortedComments;
	};

	onMount(async () => {
		await getComments();
		sortComments();
		comments.forEach((comment) => {
			checkForLinks(comment.message, `comment-${comment.id}`);
		});
	});
</script>

<SuccessPoppup bind:show message={showMessage} />

<div
	class="p-4 border border-gray-200 dark:border-gray-500 rounded darK:text-darktext"
	id="comments"
>
	<h1 class="text-left text-2xl">{$_('Comments')}</h1>
	<!-- Add Comment -->
	<CommentPost bind:proposals bind:comments parent_id={undefined} replyDepth={-1} />

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
				/>
			{:else}
				<div
					class={`p-3 text-sm border border-l-gray-400 ml-${
						comment.reply_depth < 5 ? comment.reply_depth * 2 : 10
					}`}
					class:bg-gray-100={comment.reply_depth % 2 === 1}
					class:dark:bg-darkbackground={comment.reply_depth % 2 === 1}
				>
					<!-- TODO: Improve the <ProfilePicture /> component and use it here -->
					<div class="flex gap-2">
						<img class="w-6 h-6 rounded-full" src={DefaultPFP} alt="default pfp" />
						<div class="text-gray-700 dark:text-darkmodeText">{comment.author_name}</div>
					</div>
					<div class="text-md mt-1 mb-3" id={`comment-${comment.id}`}>{comment.message}</div>
					<div class="text-xs text-gray-400 dark:text-darkmodeText">
						{comment.edited ? '(edited)' : ''}
					</div>
					{#if (comment.attachments?.length > 0)}
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
							<div
								class="flex items-center gap-1 hover:text-gray-900 text-gray-600 dark:text-darkmodeText dark:hover:text-gray-400 cursor-pointer transition-colors"
								on:click={() => (comment.being_replied = true)}
								on:keydown
							>
								<Fa icon={faReply} />{$_('Reply')}
							</div>
							{#if Number(localStorage.getItem('userId')) === comment.author_id}
								<div
									class="hover:text-gray-900 text-gray-600 dark:text-darkmodeText hover:dark:text-gray-400 cursor-pointer transition-colors"
									on:click={() => deleteComment(comment.id)}
									on:keydown
								>
									{$_('Delete')}
								</div>
								<div
									class="hover:text-gray-900 text-gray-600 dark:text-darkmodeText hover:dark:text-gray-400 cursor-pointer transition-colors"
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
				/>
			{/if}
		{/each}
	</div>
	{#if comments.length === 0}
		<div>{$_('There are currently no comments')}</div>
	{/if}
</div>

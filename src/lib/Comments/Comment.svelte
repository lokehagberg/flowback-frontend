<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Comment, proposal } from '$lib/Poll/interface';
	import { faArrowDown, faArrowUp, faReply } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import CommentPost from './CommentPost.svelte';
	import ProfilePicture from '$lib/Generic/ProfilePicture.svelte';
	import { onMount } from 'svelte';
	import { env } from "$env/dynamic/public";

	export let comment: Comment,
		comments: Comment[],
		api: 'poll' | 'thread' | 'delegate-history',
		proposals: proposal[];

	let userUpVote: -1 | 0 | 1 = 0;

	const deleteComment = async (id: number) => {
		let _api = `group/${api}/`;
		if (api === 'poll') _api += `${$page.params.pollId}/`;
		_api += `comment/${id}/delete`;

		const { res, json } = await fetchRequest('POST', _api);

		if (res.ok) {
			comments = comments.map((comment) => {
				if (comment.id !== id) return comment;

				comment.message = '[Deleted]';
				comment.active = false;
				return comment;
			});
			comments = comments;
		}
	};

	// The entire upvote-downvote system in the front end is ugly brute-force, refactoring would be neat.
	const commentVote = async (_vote: -1 | 1) => {
		let vote = {};
		let regretting = userUpVote === _vote;

		// if (regretting) vote = null;
		if (_vote === -1) vote = { vote: false };
		else if (_vote === 1) vote = { vote: true };

		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/comment/${comment.id}/vote`,
			vote
		);

		if (!res.ok) return;

		if (regretting) {
			userUpVote = 0;
			if (_vote === 1) comment.score += -1;
			else if (_vote === -1) comment.score += 1;
		} else {
			userUpVote = _vote;
			if (comment.score !== 0) comment.score += 2 * _vote;
			else comment.score += _vote;
		}
	};

	onMount(() => {
		if (comment.user_vote === null || comment.user_vote === undefined) userUpVote = 0;
		else if (comment.user_vote === true) userUpVote = 1;
		else if (comment.user_vote === false) userUpVote = -1;
	});
</script>

{#if comment.being_edited}
	<CommentPost
		bind:proposals
		bind:comments
		bind:beingEdited={comment.being_edited}
		message={comment.message}
		parent_id={comment.parent_id}
		id={comment.id}
		{api}
	/>
{:else}
	<div
		class={`p-3 text-sm border border-l-gray-400`}
		style:margin-left={`${comment.reply_depth * 10}px`}
		class:bg-gray-100={comment.reply_depth % 2 === 1}
		class:dark:bg-darkbackground={comment.reply_depth % 2 === 1}
	>
		<!-- TODO: Improve the <ProfilePicture /> component and use it here -->
		<div class="flex gap-2">
			<!-- {@debug comment} -->
			<ProfilePicture
				profilePicture={comment.author_profile_image}
				username={comment.author_name}
				displayName
			/>
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
						src={`${env.PUBLIC_API}/media/${attachment.file}`}
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
				<!-- svelte-ignore a11y-no-static-element-interactions -->
				<div
					class="flex items-center gap-1 hover:text-gray-900 text-gray-600 dark:text-darkmodeText dark:hover:text-gray-400 cursor-pointer transition-colors"
					on:click={() => commentVote(1)}
					on:keydown
				>
					<Fa icon={faArrowUp} color={userUpVote === 1 ? 'blue' : ''} />
				</div>
				<!-- svelte-ignore a11y-no-static-element-interactions -->
				<div
					class="flex items-center gap-1 hover:text-gray-900 text-gray-600 dark:text-darkmodeText dark:hover:text-gray-400 cursor-pointer transition-colors"
					on:click={() => commentVote(-1)}
					on:keydown
				>
					<Fa icon={faArrowDown} color={userUpVote === -1 ? 'blue' : ''} />
				</div>
				{comment.score}
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
		{api}
	/>
{/if}

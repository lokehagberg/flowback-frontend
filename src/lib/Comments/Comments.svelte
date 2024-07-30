<script lang="ts">
	import CommentPost from './CommentPost.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { Comment as CommentType } from '../Poll/interface';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import type { proposal } from '../Poll/interface';
	import Comment from './Comment.svelte';
	import { commentSetup, getComments } from './functions';
	import { pollComments as pollCommentsLimit } from '../Generic/APILimits.json';

	export let proposals: proposal[] = [],
		api: 'poll' | 'thread' | 'delegate-history',
		delegate_pool_id: null | number = null;

	let _comments: CommentType[] = [],
		show = false,
		showMessage = '',
		offset = 0,
		showReadMore = true;

	onMount(async () => {
		const { comments, next } = await getComments($page.params.pollId, api, offset);
		_comments = await commentSetup(comments);
		showReadMore = next !== null;
	});

	const readMore = async () => {
		offset += pollCommentsLimit;
		const { comments, next } = await getComments($page.params.pollId, api, offset);
		_comments = _comments.concat(comments);
		_comments = await commentSetup(_comments);
		_comments = _comments;
		console.log(next, 'NXT');
		showReadMore = next !== null;
	};
</script>

<SuccessPoppup bind:show message={showMessage} />

<div
	class="p-4 rounded dark:text-darktext"
	id="comments"
>
	<h1 class="text-left text-2xl">{$_('Comments')}</h1>
	<!-- Add Comment -->
	<CommentPost
		bind:proposals
		bind:comments={_comments}
		parent_id={undefined}
		{api}
		{delegate_pool_id}
	/>

	<div class="flex flex-col gap-4 mt-6">
		{#each _comments as comment}
			<Comment {comment} bind:comments={_comments} bind:api bind:proposals />
		{/each}
		{#if showReadMore}
			<!-- svelte-ignore a11y-no-static-element-interactions -->
			<div on:click={readMore} on:keydown>Read more</div>
		{/if}
	</div>
	{#if _comments.length === 0}
		<div>{$_('There are currently no comments')}</div>
	{/if}
</div>

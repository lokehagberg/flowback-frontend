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

	export let proposals: proposal[] = [],
		api: 'poll' | 'thread' | 'delegate-history',
		delegate_pool_id: null | number = null;

	let comments: CommentType[] = [],
		show = false,
		showMessage = '',
		offset = 0;

	onMount(async () => {
		comments = await getComments($page.params.pollId, api, offset);
		comments = await commentSetup(comments);
	});

	const readMore = async () => {
		offset++;
		comments = comments.concat(await getComments($page.params.pollId, api, offset));
		comments = await commentSetup(comments);
		comments = comments;
	};
</script>

<SuccessPoppup bind:show message={showMessage} />

<div
	class="p-4 border border-gray-200 dark:border-gray-500 rounded dark:text-darktext"
	id="comments"
>
	<h1 class="text-left text-2xl">{$_('Comments')}</h1>
	<!-- Add Comment -->
	<CommentPost bind:proposals bind:comments parent_id={undefined} {api} {delegate_pool_id} />

	<div class="flex flex-col gap-4 mt-6">
		{#each comments as comment}
			<Comment {comment} bind:comments bind:api bind:proposals />
		{/each}
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<div on:click={readMore} on:keydown>Read more</div>
	</div>
	{#if comments.length === 0}
		<div>{$_('There are currently no comments')}</div>
	{/if}
</div>

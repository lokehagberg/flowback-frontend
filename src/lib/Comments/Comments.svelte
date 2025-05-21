<script lang="ts">
	import CommentPost from './CommentPost.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { proposal } from '../Poll/interface';
	import Comment from './Comment.svelte';
	import { getCommentDepth, getComments } from './functions';
	import { pollComments as pollCommentsLimit } from '../Generic/APILimits.json';
	import CommentFilter from './CommentFilter.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import { commentsStore } from './commentStore';
	import type { Comment as comment} from '$lib/Poll/interface';

	export let proposals: proposal[] = [],
		api: 'poll' | 'thread' | 'delegate-history',
		delegate_pool_id: null | number = null,
		Class = '';
	
  let offset = 0,
		showReadMore = true,
		sortBy: null | string = null,
		searchString: string = '',
		poppup: poppup;

	const setUpComments = async () => {
		const { comments, next } = await getComments(getId(), api, offset, sortBy, searchString);
		
		comments.forEach((comment:comment) => {
			comment.reply_depth = getCommentDepth(comment, comments);
		});

		commentsStore.setAll(comments);
		showReadMore = next !== null;
	};

	const readMore = async () => {
		offset += pollCommentsLimit;
		const { comments, next } = await getComments(getId(), api, offset, sortBy);
		commentsStore.setAll([...$commentsStore.allComments, ...comments]);
		showReadMore = next !== null;
	};

	const getId = () => {
		if (api === 'poll') return $page.params.pollId;
		else if (api === 'thread') return $page.params.threadId;
		else if (api === 'delegate-history') return delegate_pool_id;
	};

	onMount(async () => {
		await setUpComments();

	});

	$: if (sortBy || searchString) setUpComments();
</script>

<div class={`rounded dark:text-darktext ${Class}`} id="comments">
	<div class="border-b border-gray-300">
		<!-- Add Comment -->

		<CommentPost bind:proposals {api} {delegate_pool_id} />


		<CommentFilter
			bind:sortBy
			bind:searchString
			Class="flex flex-row-reverse items-center justify-end mb-2 gap-8"
		/>
	</div>

	<div class="flex flex-col gap-1 mt-2">
		{#each $commentsStore.filteredComments as comment}
			<Comment {delegate_pool_id} {comment} {api} {proposals} />
		{/each}
		{#if showReadMore}
			<button on:click={readMore}>{$_('Read more')}</button>
		{/if}
	</div>

	{#if $commentsStore.filteredComments.length === 0}
		<div class="text-center">{$_('There are currently no comments')}</div>
	{/if}
</div>

<Poppup bind:poppup />

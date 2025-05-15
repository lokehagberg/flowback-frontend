<script lang="ts">
	import CommentPost from './CommentPost.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import { onMount, onDestroy } from 'svelte';
	import type { Comment as CommentType } from '../Poll/interface';
	import type { proposal } from '../Poll/interface';
	import Comment from './Comment.svelte';
	import { commentSetup, getComments } from './functions';
	import { pollComments as pollCommentsLimit } from '../Generic/APILimits.json';
	import CommentFilter from './CommentFilter.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import { commentsStore } from './commentStore';

	export let proposals: proposal[] = [],
		api: 'poll' | 'thread' | 'delegate-history',
		delegate_pool_id: null | number = null,
		Class = '',
		_comments: CommentType[] = [],
		_allComments: CommentType[] = [];
	let interval: any;
	let poppup: poppup,
		offset = 0,
		showReadMore = true,
		sortBy: null | string = null,
		searchString: string = '',
		done = false,
		commentSubscription: any;

	const setUpComments = async () => {
		const { comments, next } = await getComments(getId(), api, offset, sortBy, searchString);
		_comments = await commentSetup(comments);
		showReadMore = next !== null;
		_allComments = _comments;
		commentsStore.set(comments);
		// commentsStore.subscribe(commentSubscription)
		// console.log(commentsStore, "STORE");
	};

	const readMore = async () => {
		offset += pollCommentsLimit;
		const { comments, next } = await getComments(getId(), api, offset, sortBy);
		_comments = _comments.concat(comments);
		_comments = await commentSetup(_comments);
		_comments = _comments;
		showReadMore = next !== null;
	};

	const getId = () => {
		if (api === 'poll') return $page.params.pollId;
		else if (api === 'thread') return $page.params.threadId;
		else if (api === 'delegate-history') return delegate_pool_id;
	};

	onMount(async () => {
		await setUpComments();
		setUpComments();
	});
	onDestroy(() => {
		clearInterval(interval);
	});
	$: if (sortBy || !sortBy || searchString) setUpComments();
	$: if (_comments) {
		done = false;
		console.log('changed comments', _comments);
	}
</script>

<div class={`rounded dark:text-darktext ${Class}`} id="comments">
	<div class="border-b border-gray-300">
		<!-- Add Comment -->
		<CommentPost
			bind:proposals
			bind:comments={_allComments}
			parent_id={undefined}
			{api}
			{delegate_pool_id}
		/>

		<CommentFilter
			bind:sortBy
			bind:searchString
			Class="flex flex-row-reverse items-center justify-end mb-2 gap-8"
		/>
	</div>

	<div class="flex flex-col gap-1 mt-2">
		{#each _comments as comment}
			<Comment {delegate_pool_id} {comment} bind:comments={_comments} {api} {proposals} />
		{/each}
		{#if showReadMore}
			<button on:click={readMore}>{$_('Read more')}</button>
		{/if}
	</div>

	{#if _comments.length === 0}
		<div class="text-center">{$_('There are currently no comments')}</div>
	{/if}
</div>

<Poppup bind:poppup />

<script lang="ts">
	import CommentPost from './CommentPost.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { Comment as CommentType } from '../Poll/interface';
	import type { proposal } from '../Poll/interface';
	import Comment from './Comment.svelte';
	import { commentSetup, getComments } from './functions';
	import { pollComments as pollCommentsLimit } from '../Generic/APILimits.json';
	import CommentFilter from './CommentFilter.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';

	export let proposals: proposal[] = [],
		api: 'poll' | 'thread' | 'delegate-history',
		delegate_pool_id: null | number = null,
		Class = '';

	let _comments: CommentType[] = [],
		poppup: poppup,
		offset = 0,
		showReadMore = true,
		sortBy: null | string = null;



	const setUpComments = async () => {
		const { comments, next } = await getComments(getId(), api, offset, sortBy);
		_comments = await commentSetup(comments);
		showReadMore = next !== null;
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
		if (api === 'poll') return $page.params.pollId
		else if (api === 'thread') return $page.params.threadId
		else if (api === 'delegate-history') return delegate_pool_id
	}

	onMount(async () => {
		setUpComments();
	});

	$: if (sortBy || !sortBy) setUpComments();
</script>

<div class={`rounded dark:text-darktext ${Class}`} id="comments">
	<!-- Add Comment -->
	<CommentPost
		bind:proposals
		bind:comments={_comments}
		parent_id={undefined}
		{api}
		{delegate_pool_id}
	/>

	<CommentFilter bind:sortBy Class="inline"/>

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

<Poppup bind:poppup />

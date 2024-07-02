<script lang="ts">
	import CommentPost from './CommentPost.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { Comment as CommentType } from '../Poll/interface';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import type { proposal } from '../Poll/interface';
	import Comment from './Comment.svelte';
	import { commentSetup } from './functions';
	import { pollComments as pollCommentsLimit } from '../Generic/APILimits.json';
	import { fetchRequest } from '$lib/FetchRequest';

	export let proposals: proposal[] = [],
		api: 'poll' | 'thread' | 'delegate-history',
		delegate_pool_id: null | number = null;

	let comments: CommentType[] = [],
		show = false,
		showMessage = '';

	const getComments = async (id: number | string) => {
		let _api = '';

		if (api === 'poll') _api += `group/poll/${id}`;
		else if (api === 'thread') _api += `group/thread/${id}`;
		else if (api === 'delegate-history') _api += `group/delegate/pool/${1}`;

		_api += `/comment/list?limit=${pollCommentsLimit}`;

		const { res, json } = await fetchRequest('GET', _api);

		comments = json.results.map((comment: CommentType) => {
			comment.being_edited = false;
			comment.being_replied = false;
			return comment;
		});
	};

	onMount(async () => {
		await getComments($page.params.pollId)
		comments = await commentSetup(comments);
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
		{api}
		{delegate_pool_id}
	/>

	<div class="flex flex-col gap-4 mt-6">
		{#each comments as comment}
			<Comment {comment} bind:comments bind:api bind:proposals />
		{/each}
	</div>
	{#if comments.length === 0}
		<div>{$_('There are currently no comments')}</div>
	{/if}
</div>

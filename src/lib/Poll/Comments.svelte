<script lang="ts">
	import CommentPost from './CommentPost.svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { Comment, Phase } from './interface';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import { faReply } from '@fortawesome/free-solid-svg-icons/faReply';
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { proposal } from './interface';

	let message: string,
		comments: Comment[] = [],
		show = false,
		showMessage = '',
		recentlyTappedButton = '';

	export let proposals: proposal[] = [];

	const postComment = async (parent_id: number | undefined = undefined, replyDepth: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/comment/create`,
			{
				message,
				parent_id
			}
		);
		if (res.ok) {
			const parentPosition = comments.findIndex((parent) => parent.id === parent_id);
			comments.splice(parentPosition + 1, 0, {
				author_id: Number(localStorage.getItem('userId')) || 0,
				author_name: localStorage.getItem('userName') || '',
				author_thumbnail: '',
				message,
				parent_id: parent_id || undefined,
				score: 0,
				being_edited: false,
				being_replied: false,
				id: json,
				reply_depth: replyDepth + 1,
				active: true
			});
			comments = comments;
			showMessage = 'Posted Comment';
			show = true;
			message = '';

			subscribeToReplies();
		}
	};

	const subscribeToReplies = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/subscribe`,
			{
				categories: ['comment_self']
			}
		);
	};

	const getComments = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/comment/list?limit=10000`
		);

		comments = json.results.map((comment: Comment) => {
			comment.being_edited = false;
			comment.being_replied = false;
			return comment;
		});
	};

	const updateComment = async (id: number, message: string) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/comment/${id}/update`,
			{
				message
			}
		);
		if (res.ok) {
			show = true;
			showMessage = 'Edited Comment';
			const index = comments.findIndex((comment) => comment.id === id);
			let comment = comments.find((comment) => comment.id === id);
			if (comment) {
				comment.message = message;
				comments.splice(index, 1, comment);
				comments = comments;
			}
		}
	};

	const deleteComment = async (id: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/comment/${id}/delete`
		);
		if (res.ok) {
			show = true;
			showMessage = 'Comment Deleted';
			comments = comments.filter((comment) => comment.id !== id);
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
	});
</script>

<SuccessPoppup bind:show message={showMessage} />

<div class="p-4 border border-gray-200 rounded" id="comments">
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
						comment.reply_depth < 10 ? comment.reply_depth * 2 : 20
					}`}
					class:bg-gray-100={comment.reply_depth % 2 === 1}
				>
					<!-- TODO: Improve the <ProfilePicture /> component and use it here -->
					<div class="flex gap-2">
						<img class="w-6 h-6 rounded-full" src={DefaultPFP} alt="default pfp" />
						<div class="text-gray-700">{comment.author_name}</div>
					</div>
					<div class="text-md mt-1 mb-3">{comment.message}</div>
					{#if comment.active}
						<div class="flex gap-3 text-xs">
							<div
								class="flex items-center gap-1 hover:text-gray-900 text-gray-600 cursor-pointer transition-colors"
								on:click={() => (comment.being_replied = true)}
							>
								<Fa icon={faReply} />{$_('Reply')}
							</div>
							{#if Number(localStorage.getItem('userId')) === comment.author_id}
								<div
									class="hover:text-gray-900 text-gray-600 cursor-pointer transition-colors"
									on:click={() => deleteComment(comment.id)}
								>
									{$_('Delete')}
								</div>
								<div
									class="hover:text-gray-900 text-gray-600 cursor-pointer transition-colors"
									on:click={() => {
										comment.being_edited = true;
										comment.being_edited_message = comment.message;
									}}
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
</div>

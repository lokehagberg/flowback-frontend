<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import type { Comment } from './interface';
	import type { proposal } from './interface';

	export let comments: Comment[] = [],
		proposals: proposal[] = [],
		parent_id: number | undefined = undefined,
		replyDepth: number,
		id = 0,
		beingEdited = false,
		message = '',
        replying = false;

	let show = false,
		showMessage = '',
		recentlyTappedButton = '';

	const postComment = async () => {
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
				active: true,
				edited: false,

			});
			comments = comments;
			showMessage = 'Posted Comment';
			show = true;
			message = '';

			subscribeToReplies();
		}
        replying = false;
	};

	const updateComment = async () => {
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
				comment.edited = true;
			}
		}
		beingEdited = false;
	};

	//TODO: Optimize so that this doesn't fire every time a comment is made
	const subscribeToReplies = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/subscribe`,
			{
				categories: ['comment_self']
			}
		);
	};
</script>

<form
	class="mt-4 relative"
	on:submit|preventDefault={() => (beingEdited ? updateComment() : postComment())}
>
	<!-- When # typed, show proposals to be tagged -->
	<div
		class="invisible absolute bg-white dark:bg-darkbackground shadow w-full bottom-full"
		class:!visible={recentlyTappedButton === '#'}
	>
		<ul>
			{#each proposals as proposal}
				<li
					class="hover:bg-gray-100 dark:hover:bg-darkbackground dark:hover:brightness-125 cursor-pointer px-2 py-1"
					on:click={() => {
						message = `${message}${proposal.title.replaceAll(' ', '-')} `;
						recentlyTappedButton = '';
					}}
					on:keydown
				>
					{proposal.title}
				</li>
			{/each}
		</ul>
	</div>
	<TextArea label="Comment" required bind:value={message} bind:recentlyTappedButton />
	<Button Class="mt-4" type="submit" label="Send" />
</form>
 
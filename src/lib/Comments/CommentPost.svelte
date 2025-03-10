<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import type { Comment } from '../Poll/interface';
	import type { proposal } from '../Poll/interface';
	import { getCommentDepth } from './functions';
	import FileUploads from '$lib/Generic/FileUploads.svelte';
	import Fa from 'svelte-fa';
	import { faPaperPlane } from '@fortawesome/free-solid-svg-icons';

	export let comments: Comment[] = [],
		proposals: proposal[] = [],
		parent_id: number | undefined = undefined,
		id = 0,
		beingEdited = false,
		message = '',
		replying = false,
		api: 'poll' | 'thread' | 'delegate-history',
		delegate_pool_id: number | null = null;

	let show = false,
		showMessage = '',
		recentlyTappedButton = '',
		attachments: File[] = [],
		images: File[];

	// $: if(image !== null ) attachments.push(image)

	const getId = () => {
		if (api === 'poll') return `poll/${$page.params.pollId}`;
		else if (api === 'thread') return `thread/${$page.params.threadId}`;
		else if (api === 'delegate-history') return `delegate/pool/${delegate_pool_id}`;
	};

	const commentCreate = async () => {
		const formData = new FormData();
		formData.append('message', message);
		//@ts-ignore
		if (parent_id) formData.append('parent_id', parent_id);
		// await console.log(await image.text())
		if (images)
			images.forEach((image) => {
				formData.append('attachments', image);
			});

		const { res, json } = await fetchRequest(
			'POST',
			`group/${getId()}/comment/create`,
			formData,
			true,
			false
		);

		if (!res.ok) return;

		let newComment: Comment = {
			user_vote: true,
			active: true,
			author_id: Number(window.localStorage.getItem('userId')) || 0,
			author_name: window.localStorage.getItem('userName') || '',
			being_edited: false,
			being_replied: false,
			score: 1,
			edited: false,
			attachments: images.map((image) => {
				return { file: URL.createObjectURL(image) };
			}),
			message,
			id: json,
			parent_id,
			author_profile_image: window.localStorage.getItem('pfp-link') || '',
			being_edited_message: '',
			reply_depth: comments.find((comment) => comment.id === parent_id)?.reply_depth || 0
		};

		// Find the index where to insert the new reply
		let insertIndex;
		if (parent_id) {
			// Find the last reply in the chain for this parent
			let parentIndex = comments.findIndex((c) => c.id === parent_id);
			let replyDepth = comments[parentIndex].reply_depth + 1;

			// Find the last comment in the reply chain
			insertIndex = parentIndex + 1;
			while (
				insertIndex < comments.length &&
				comments[insertIndex].reply_depth > comments[parentIndex].reply_depth
			) {
				insertIndex++;
			}

			newComment.reply_depth = replyDepth;
		} else {
			// If it's a top-level comment, add it to the beginning
			insertIndex = 0;
			newComment.reply_depth = 0;
		}

		// Insert the new comment at the correct position
		comments.splice(insertIndex, 0, newComment);
		comments = comments;

		showMessage = 'Successfully posted comment';
		show = true;
		message = '';
		replying = false;

		subscribeToReplies();
	};

	const commentUpdate = async () => {
		const formData = new FormData();
		formData.append('message', message);
		//@ts-ignore
		if (parent_id) formData.append('parent_id', parent_id);
		// await console.log(await image.text())
		if (images)
			images.forEach((image) => {
				formData.append('attachments', image);
			});

		const { res, json } = await fetchRequest(
			'POST',
			`group/${getId()}/comment/${id}/update`,
			formData,
			true,
			false
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
		const { res, json } = await fetchRequest('POST', `group/${getId()}/subscribe`, {
			categories: ['comment_self']
		});
	};
</script>

<form
	class="relative"
	on:submit|preventDefault={() => (beingEdited ? commentUpdate() : commentCreate())}
>
	<!-- When # typed, show proposals to be tagged -->
	<div
		class="hidden absolute z-50 bg-white dark:bg-darkbackground shadow w-full bottom-full"
		class:!block={recentlyTappedButton === '#'}
	>
		{#if proposals}
			{#each proposals as proposal}
				<button
					class="hover:bg-gray-100 dark:hover:bg-darkbackground dark:hover:brightness-125 cursor-pointer px-2 py-1"
					on:click={() => {
						message = `${message}${proposal.title.replaceAll(' ', '-')} `;
						recentlyTappedButton = '';
					}}
					on:keydown
				>
					{proposal.title}
				</button>
			{/each}
		{/if}
	</div>
	<div class="flex">
		<div class="flex flex-grow">
			<TextArea
				label=""
				bind:value={message}
				bind:recentlyTappedButton
				inputClass="bg-gray-100 border-0 placeholder-gray-600 pl-2 max-h-[15rem]"
				Class="w-full"
				placeholder={$_('Write a comment...')}
				displayMax={false}
				id="comment"
			/>
		</div>
		<div class="flex ml-2">
			<FileUploads bind:images minimalist disableCropping />
			<Button Class="bg-white" type="submit" label=""
				><Fa icon={faPaperPlane} color="black" /></Button
			>
		</div>
	</div>
</form>

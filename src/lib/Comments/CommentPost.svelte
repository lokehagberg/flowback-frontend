<script lang="ts">
	import { darkModeStore } from '$lib/Generic/DarkMode';
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import type { Comment } from '../Poll/interface';
	import type { proposal } from '../Poll/interface';
	import FileUploads from '$lib/Generic/File/FileUploads.svelte';
	import Fa from 'svelte-fa';
	import { faPaperPlane } from '@fortawesome/free-solid-svg-icons';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import { commentsStore } from './commentStore';
	import { getCommentDepth } from './functions';
	import { userStore } from '$lib/User/interfaces';

	export let comments: Comment[] = [],
		proposals: proposal[] = [],
		parent_id: number | null = null,
		id = 0,
		beingEdited = false,
		message = '',
		replying = false,
		api: 'poll' | 'thread' | 'delegate-history',
		delegate_pool_id: number | null = null,
		files: File[] = [];

	let show = false,
		showMessage = '',
		recentlyTappedButton = '',
		filteredProposal: proposal | null = null;

	// Reactive subscription to the filtered proposal in the commentsStore
	$: filteredProposal = $commentsStore.filterByProposal;

	const getId = () => {
		if (api === 'poll') return `poll/${$page.params.pollId}`;
		else if (api === 'thread') return `thread/${$page.params.threadId}`;
		else if (api === 'delegate-history')
			return `delegate/pool/${delegate_pool_id}`;
	};

	const commentCreate = async () => {
		const formData = new FormData();

		// Prepend the hashtag to the message if a proposal is filtered
		if (filteredProposal) {
			message = `#${filteredProposal.title.replaceAll(' ', '-')} ${message}`;
		}

		if (message !== '') formData.append('message', message);
		if (parent_id) formData.append('parent_id', parent_id.toString());
		if (files)
			files.forEach((file) => {
				formData.append('attachments', file);
			});

		const { res, json } = await fetchRequest(
			'POST',
			`group/${getId()}/comment/create`,
			formData,
			true,
			false
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to post comment',
				success: false
			});
			return;
		}

		// Calculate the reply_depth based on the parent comment

		const id = json;
		getNewComment(id);
	};

	const getNewComment = async (id: number) => {
		let replyDepth = 0;

		const { res, json } = await fetchRequest(
			'GET',
			`group/${getId()}/comment/list?id=${id}`
		);

		if (res.ok) {
			const newComment = json.results[0];
			commentsStore.add(newComment);
			comments = comments;
			showMessage = 'Successfully posted comment';
			show = true;
			message = '';
			replying = false;

			subscribeToReplies();

			return;
		}

		const parentComment = $commentsStore.allComments.find(
			(comment) => comment.id === parent_id
		);

		if (parentComment) {
			replyDepth =
				getCommentDepth(parentComment, $commentsStore.allComments) + 1;
		}

		const newComment: Comment = {
			id: json,
			message,
			attachments: files.map((file) => ({ file: URL.createObjectURL(file) })),
			parent_id,
			reply_depth: replyDepth,
			author_id: $userStore?.id || -1,
			author_name: $userStore?.username || '',
			author_profile_image: $userStore?.profile_image || '',
			score: 1,
			active: true,
			edited: false,
			being_edited: false,
			being_replied: false,
			being_reported: false,
			user_vote: true,
			being_edited_message: ''
		};

		comments = comments;

		commentsStore.add(newComment);

		showMessage = 'Successfully posted comment';
		show = true;
		message = '';
		replying = false;

		subscribeToReplies();
	};

	const commentUpdate = async () => {
		const formData = new FormData();

		if (message === '' && files.length === 0) {
			ErrorHandlerStore.set({
				message: 'Cannot create empty comment',
				success: false
			});
			return;
		}

		if (message !== '') formData.append('message', message);
		if (parent_id) formData.append('parent_id', parent_id.toString());
		if (files)
			files.forEach((image) => {
				formData.append('attachments', image);
			});

		const { res, json } = await fetchRequest(
			'POST',
			`group/${getId()}/comment/${id}/update`,
			formData,
			true,
			false
		);

		beingEdited = false;

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Failed to edit comment',
				success: false
			});
			return;
		}

		show = true;
		showMessage = $_('Edited Comment');
		const index = comments?.findIndex((comment) => comment.id === id);
		let comment = comments?.find((comment) => comment.id === id);
		if (comment) {
			comment.message = message;
			comments.splice(index, 1, comment);
			comments = comments;
			comment.edited = true;
			comment.attachments = files.map((image) => {
				return { file: URL.createObjectURL(image) };
			});
		}
	};

	//TODO: Optimize so that this doesn't fire every time a comment is made
	const subscribeToReplies = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${getId()}/notification/subscribe`,
			{
				tags: ['comment_self']
			}
		);
	};
</script>

<form
	class="relative"
	on:submit|preventDefault={() =>
		beingEdited ? commentUpdate() : commentCreate()}
>
	<!-- When # typed, show proposals to be tagged -->
	<div
		class="hidden absolute z-50 bg-white dark:bg-darkbackground shadow w-full top-full border-gray-300 rounded"
		class:!block={recentlyTappedButton === '#'}
	>
		{#if proposals?.length > 0 && api === 'poll'}
			<div class="max-h-30 overflow-y-auto">
				<div
					class="px-4 py-2 font-semibold text-sm text-gray-600 border-b border-gray-200"
				>
					{$_('All proposals')}
				</div>
				<ul class="divide-y divide-gray-200">
					{#each proposals as proposal}
						<li class="px-4 py-2">
							<button
								type="button"
								class="w-full text-left hover:bg-gray-100 dark:hover:bg-darkbackground dark:hover:brightness-125 cursor-pointer"
								on:click={() => {
									message = `${message}${proposal.title.replaceAll(' ', '-')} `;
									recentlyTappedButton = '';
								}}
							>
								{proposal.title}
							</button>
						</li>
					{/each}
				</ul>
			</div>
		{/if}
	</div>
	<div class="flex">
		<div class="flex flex-grow">
			<!-- TODO: Fix so there's dynamic sizing of the number of rows instead of fixed at 6 or 3 -->
			<TextArea
				label=""
				bind:value={message}
				bind:recentlyTappedButton
				inputClass="bg-gray-100 border-0 placeholder-gray-600 pl-2 max-h-[15rem]"
				Class="w-full"
				placeholder={$_('Write a comment...')}
				displayMax={false}
				id="textarea-comment"
				rows={beingEdited && message.length > 50 ? 6 : 3}
			/>
		</div>
		<div class="flex ml-2 items-start">
			<FileUploads
				bind:files
				minimalist
				disableCropping
				Class="content-center p-2 rounded dark:hover:bg-gray-700 hover:bg-gray-100 h-10"
			/>
			<div class="p-2 m-auto">
				<Button
					Class="submit-button bg-white dark:bg-darkbackground hover:!brightness-100 dark:hover:!bg-gray-700 hover:bg-gray-100"
					type="submit"
					label=""
					><Fa
						icon={faPaperPlane}
						color={$darkModeStore ? 'white' : 'black'}
						class="text-lg"
					/></Button
				>
			</div>
		</div>
	</div>
</form>

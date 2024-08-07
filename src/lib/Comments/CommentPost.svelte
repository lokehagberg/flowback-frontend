<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import type { Comment } from '../Poll/interface';
	import type { proposal } from '../Poll/interface';
	import ImageUpload from '$lib/Generic/ImageUpload.svelte';
	import { faUser } from '@fortawesome/free-solid-svg-icons/faUser';
	import { commentSetup, getCommentDepth } from './functions';
	import FileUploads from '$lib/Generic/FileUploads.svelte';

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
		if (res.ok) {
			let newComment: Comment = {
				user_vote: null,
				active: true,
				author_id: Number(window.localStorage.getItem('userId')) || 0,
				author_name: window.localStorage.getItem('userName') || '',
				being_edited: false,
				being_replied: false,
				score: 0,
				edited: false,
				//TODO Fix so attachments show up immediately
				attachments: [],
				message,
				id: json,
				parent_id,
				author_thumbnail: window.localStorage.getItem('pfp-link') || '',
				being_edited_message: '',
				reply_depth: 0
			};

			newComment.reply_depth = getCommentDepth(newComment, comments);

			const i = comments.findIndex((comment) => comment.id === parent_id);
			comments.splice(i + 1, 0, newComment);

			comments = comments;

			console.log(comments);

			// comments = await commentSetup(comments);
			showMessage = 'Successfully posted comment';
			show = true;
			message = '';

			subscribeToReplies();
		}
		replying = false;
	};

	const commentUpdate = async () => {
		const { res, json } = await fetchRequest('POST', `group/${getId()}/comment/${id}/update`, {
			message
		});
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
	class="mt-4 relative"
	on:submit|preventDefault={() => (beingEdited ? commentUpdate() : commentCreate())}
>
	<!-- When # typed, show proposals to be tagged -->
	<div
		class="invisible absolute bg-white dark:bg-darkbackground shadow w-full bottom-full"
		class:!visible={recentlyTappedButton === '#'}
	>
		<ul>
			{#each proposals as proposal}
				<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
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
	<TextArea label="Comment" bind:value={message} bind:recentlyTappedButton />
	<FileUploads bind:images />
	<!-- <ImageUpload
		icon={faUser}
		shouldCrop={false}
		bind:croppedImage={image}
		label=""
		iconSize={'2x'}
		Class="flex !flex-row-reverse"
		minimalist
	/> -->
	<!-- {#if message !== "" || attachments.length > 0} -->
	<Button Class="mt-4" type="submit" label="Send" />
	<!-- {/if} -->
</form>

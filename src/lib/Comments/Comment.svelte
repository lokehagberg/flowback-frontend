<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import type { Comment } from '$lib/Poll/interface';
	import { faReply } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';

	export let comment: Comment, comments: Comment[], api: 'poll' | 'thread' | 'delegate-history';

	const deleteComment = async (id: number) => {
		let _api = `group/${api}/`;

		if (api === 'poll') _api += `${$page.params.pollId}/`;
		// else if (api === 'thread') _api += `${$page.params.threadId}`;

		_api += `comment/${id}/delete`;

		const { res, json } = await fetchRequest('POST', _api);

		if (res.ok) {
			comments = comments.map((comment) => {
				if (comment.id !== id) return comment;

				comment.message = '[Deleted]';
				comment.active = false;
				return comment;
			});

			// console.log("THE COMMENT", comment, id)
			// if (comment === undefined) return;
			// comment.message = '[Deleted]';
			comments = comments;
		}
	};
</script>

<div
	class={`p-3 text-sm border border-l-gray-400`}
	style:margin-left={`${comment.reply_depth * 10}px`}
	class:bg-gray-100={comment.reply_depth % 2 === 1}
	class:dark:bg-darkbackground={comment.reply_depth % 2 === 1}
>
	<!-- TODO: Improve the <ProfilePicture /> component and use it here -->
	<div class="flex gap-2">
		<!-- <img class="w-6 h-6 rounded-full" src={DefaultPFP} alt="default pfp" /> -->
		<!-- <ProfilePicture user={comment}/> -->
		<div class="text-gray-700 dark:text-darkmodeText">{comment.author_name}</div>
	</div>
	<div class="text-md mt-1 mb-3 break-words" id={`comment-${comment.id}`}>
		{comment.message}
	</div>
	<div class="text-xs text-gray-400 dark:text-darkmodeText">
		{comment.edited ? '(edited)' : ''}
	</div>
	{#if comment.attachments?.length > 0}
		<div>
			{#each comment.attachments as attachment}
				<img
					class=""
					src={`${import.meta.env.VITE_API}/media/${attachment.file}`}
					alt="attachment to the comment"
				/>
			{/each}
		</div>
	{/if}
	{#if comment.active}
		<div class="flex gap-3 text-xs">
			<!-- svelte-ignore a11y-no-static-element-interactions -->
			<div
				class="flex items-center gap-1 hover:text-gray-900 text-gray-600 dark:text-darkmodeText dark:hover:text-gray-400 cursor-pointer transition-colors"
				on:click={() => (comment.being_replied = true)}
				on:keydown
			>
				<Fa icon={faReply} />{$_('Reply')}
			</div>
			{#if Number(localStorage.getItem('userId')) === comment.author_id}
				<!-- svelte-ignore a11y-no-static-element-interactions -->
				<div
					class="hover:text-gray-900 text-gray-600 dark:text-darkmodeText hover:dark:text-gray-400 cursor-pointer transition-colors"
					on:click={() => deleteComment(comment.id)}
					on:keydown
				>
					{$_('Delete')}
				</div>
				<!-- svelte-ignore a11y-no-static-element-interactions -->
				<div
					class="hover:text-gray-900 text-gray-600 dark:text-darkmodeText hover:dark:text-gray-400 cursor-pointer transition-colors break-words"
					on:click={() => {
						comment.being_edited = true;
						comment.being_edited_message = comment.message;
					}}
					on:keydown
				>
					{$_('Edit')}
				</div>
			{/if}
		</div>
	{/if}
</div>

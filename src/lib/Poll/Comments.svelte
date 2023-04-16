<script lang="ts">
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
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import Fa from 'svelte-fa/src/fa.svelte';

	let message: string,
		comments: Comment[] = [],
		show = false;


	const postComment = async (parent: number | null = null) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/comment/create`,
			{
				message,
				parent
			}
		);
		if (res.ok) {
			comments.reverse().push({
				author_id: Number(localStorage.getItem('userId')) || 0,
				author_name: localStorage.getItem('userName') || '',
				author_thumbnail: '',
				message,
				parent: 2,
				score: 0,
				being_edited: false,
				being_replied: false
			});
			comments = comments.reverse();
			show = true;
		}
	};

	const getComments = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/poll/${$page.params.pollId}/comment/list`
		);
		
		comments = json.results.map((comment:Comment) => {
			comment.being_edited = false
			comment.being_replied = false
			return comment
		})
	};

	const updateComment = async () => {};

	const deleteComment = async (id: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/comment/${id}/delete`
		);
	};

	onMount(() => {
		getComments();
	});
</script>

<SuccessPoppup bind:show message={'Comment Posted'} />

<div class="p-4 border border-gray-200 rounded">
	<h1 class="text-left text-2xl">{$_('Comments')}</h1>
	<form class="mt-4" on:submit|preventDefault={() => postComment(null)}>
		<TextArea label="Comment" required bind:value={message} />
		<Button Class="mt-4" type="submit" label="Send" />
	</form>

	<div class="flex flex-col gap-4 mt-6">
		{#each comments as comment}
			{#if comment?.being_edited}
				<form class="ml-4" on:submit|preventDefault={() => updateComment()}>
					<TextArea label="Comment" required bind:value={message} />
					<Button Class="mt-4" type="submit" label="Update" />
				</form>
			{:else}
				<div class=" p-3 text-sm">
					<!-- TODO: Improve the <ProfilePicture /> component and use it here -->
					<div class="flex gap-2">
						<img class="w-6 h-6 rounded-full" src={DefaultPFP} alt="default pfp" />
						<div class="text-gray-700">{comment.author_name}</div>
					</div>
					<div class="text-md mt-1 mb-3">{comment.message}</div>
					<div class="flex gap-3 text-xs">
						<div
							class="flex items-center gap-1 hover:text-gray-900 text-gray-600 cursor-pointer transition-colors"
							on:click={() => (comment.being_replied = true)}
						>
							<Fa icon={faReply} />Reply
						</div>
						{#if Number(localStorage.getItem('userId')) === comment.author_id}
							<div
								class="hover:text-gray-900 text-gray-600 cursor-pointer transition-colors"
								on:click={() => deleteComment(1)}
							>
								Delete
							</div>
							<div class="hover:text-gray-900 text-gray-600 cursor-pointer transition-colors">
								Edit
							</div>
						{/if}
					</div>
				</div>
			{/if}
			{#if comment?.being_replied}
				<form class="ml-4" on:submit|preventDefault={() => postComment(comment.author_id)}>
					<TextArea label="Reply to comment" required bind:value={message} />
					<Button Class="mt-4" type="submit" label="Send" />
				</form>
			{/if}
		{/each}
		<div class="border border-gray-400 p-4 ml-4">
			<div class="flex gap-3">
				<img class="w-8 h-8 rounded-full" src={DefaultPFP} alt="default pfp" />
				<div>Nerd</div>
			</div>
			<div>I disagree</div>
		</div>
	</div>
</div>

<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import DefaultPFP from '$lib/assets/Default_pfp.png';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import type { Comment } from './interface';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';

	let message: string,
		parent: number,
		comments: Comment[] = [],
		show = false;

	const postComment = async () => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/${$page.params.pollId}/comment/create`,
			{
				message
			}
		);
		if (res.ok) {
			comments.reverse().push({
				author_id: Number(localStorage.getItem('userId')) || 0,
				author_name: localStorage.getItem('userName') || '',
				author_thumbnail: '',
				message,
				parent: 2,
				score: 0
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
		comments = json.results;
	};

	onMount(() => {
		getComments();
	});
</script>

<SuccessPoppup bind:show message={"Comment Posted"}/>

<div class="p-4 border border-gray-200 rounded">
	<h1 class="text-left text-2xl">{$_('Comments')}</h1>
	<form class="mt-4" on:submit|preventDefault={postComment}>
		<TextArea label="Comment" required bind:value={message} />
		<Button Class="mt-4" type="submit" label="Skicka" />
	</form>

	<div class="flex flex-col gap-4 mt-6">
		{#each comments as comment}
			<div class="border border-gray-400 p-4">
				<div class="flex gap-3">
					<img class="w-8 h-8 rounded-full" src={DefaultPFP} alt="default pfp" />
					<div>{comment.author_name}</div>
				</div>
				<div>{comment.message}</div>
				<!-- <div class="flex"><HeaderIcon /> Reply</div> -->
			</div>
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

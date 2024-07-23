<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Layout from '$lib/Generic/Layout.svelte';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import type { Thread } from '$lib/Group/interface';
	import Comments from '$lib/Comments/Comments.svelte';
	import type { Comment } from '$lib/Poll/interface';

	let thread: Thread, comments: Comment[];

	onMount(() => {
		getThread();
		console.log($page.params.threadId, "THREADID")
	});

	const getThread = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/thread/list?id=${$page.params.threadId}`
		);
		console.log(json, 'JSON');
		if (!res.ok) return;

		thread = json.results[0];
	};
</script>

<Layout centered>
	{#if thread}
		<div
			class="p-10 m-10 bg-white dark:bg-darkobject dark:text-darkmodeText rounded shadow pt-6 flex flex-col gap-8 w-full md:w-3/4 lg:w-2/3 lg:max-w-[1000px]"
		>
			<h1 class="text-left text-2xl">{thread.title}</h1>

			<Comments api={'thread'} />
		</div>
	{/if}
</Layout>

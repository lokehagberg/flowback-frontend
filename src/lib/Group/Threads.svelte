<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { Thread } from './interface';
	import Pagination from '$lib/Generic/Pagination.svelte';
	import { goto } from '$app/navigation';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';

	let threads: Thread[] = [],
		prev = '',
		next = '',
		poppup: poppup;

	const getThreads = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/thread/list?limit=2`,
			{}
		);

		if (!res.ok) {
			poppup = { message: 'Could not load threads', success: false };
			return;
		}

		next = json.next;
		prev = json.previous;
		threads = json.results;
	};

	onMount(() => {
		getThreads();
	});
</script>

<div>
	{#if threads.length === 0}
		<div
			class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 shadow-lg rounded-md mb-6 text-center"
		>
			There are currently no threads in this group
		</div>
	{/if}
	{#each threads as thread}
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<div
			class="bg-white flex justify-between dark:bg-darkobject dark:text-darkmodeText p-6 shadow-lg rounded-md mb-6"
		>
			<span
				class="cursor-pointer hover:underline"
				on:click={() => goto(`${$page.params.groupId}/thread/${thread.id}`)}
				on:keydown>{thread.title}</span
			>
			<NotificationOptions
				api={`group/thread/${thread.id}`}
				categories={['comment']}
				id={thread.id}
				labels={['comment']}
			/>
		</div>
	{/each}
	<Pagination bind:prev bind:next bind:iterable={threads} />
</div>

<Poppup bind:poppup />

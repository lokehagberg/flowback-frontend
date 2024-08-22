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
	import Fa from 'svelte-fa';
	import { faComment } from '@fortawesome/free-solid-svg-icons';
	import { threads as threadsLimit } from '$lib/Generic/APILimits.json';

	let threads: Thread[] = [],
		prev = '',
		next = '',
		poppup: poppup;

	const getThreads = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/thread/list?limit=${threadsLimit}`
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
		<div class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 shadow-lg rounded-md mb-6">
			<div class="flex justify-between items-center">
				<span
					class="cursor-pointer hover:underline text-primary font-bold text-2xl"
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
			{#if thread.description}
				<span>
					{thread.description}
				</span>
			{/if}

			<div
				class="hover:bg-gray-100 dark:hover:bg-slate-500 cursor-pointer text-sm text-gray-600 dark:text-darkmodeText mt-3"
			>
				<!-- svelte-ignore a11y-missing-attribute -->
				<a
					class="text-black dark:text-darkmodeText"
					on:click={() => goto(`${$page.params.groupId}/thread/${thread.id}`)}
					on:keydown
				>
					<Fa class="inline" icon={faComment} />
					<span class="inline">{thread.total_comments} {'comments'}</span>
				</a>
			</div>
		</div>
	{/each}
	<Pagination bind:prev bind:next bind:iterable={threads} />
</div>

<Poppup bind:poppup />

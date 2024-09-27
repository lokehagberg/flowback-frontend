<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import type { Thread } from '$lib/Group/interface';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import Fa from 'svelte-fa';
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import { _ } from 'svelte-i18n';
	import ThreadDescription from '$lib/Group/ThreadDescription.svelte';
	import Comments from '$lib/Comments/Comments.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Poppup from '$lib/Generic/Poppup.svelte';
	import type { poppup } from '$lib/Generic/Poppup';

	let thread: Thread, poppup: poppup;

	onMount(() => {
		getThread();
	});

	const getThread = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/thread/list?id=${$page.params.threadId}`
		);

		if (!res.ok) {
			poppup = { message: 'Could not get Thread', success: false };
			return;
		}

		thread = json.results[0];
		if (thread.description === null) thread.description = '';
	};
</script>

<Layout centered>
	{#if thread}
		<div
			class="pt-4 max-w-[1000px] bg-white dark:bg-darkobject dark:text-darkmodeText rounded shadow w-full poll-header-grid items-center"
		>
			<div
				class="cursor-pointer bg-white dark:bg-darkobject dark:text-darkmodeText justify-center m-auto"
				on:click={() => goto(`/groups/${$page.params.groupId}`)}
				on:keydown
				role="button"
				tabindex="0"
			>
				<Fa icon={faArrowLeft} />
			</div>

			<h1 class="text-left text-2xl text-primary font-bold">{thread.title}</h1>

			<NotificationOptions
				id={thread.id}
				api={`group/thread/${thread.id}`}
				categories={['thread']}
				labels={['thread']}
			/>

			{#if thread.description.length > 0}
				<div class="grid-area-description">
					<ThreadDescription bind:description={thread.description} limit={500} Class="" />
				</div>
			{/if}
		</div>
	{/if}

	<Comments api={'thread'} Class="w-full max-w-[1000px] bg-white dark:bg-darkobject p-6 mt-6" />
</Layout>

<Poppup bind:poppup />

<style>
	.poll-header-grid {
		display: grid;
		grid-template-columns: 0.3fr 4fr 0.3fr;
		grid-template-rows: 0.1fr 0.1fr 1fr;
	}

	.grid-area-items {
		grid-area: 2 / 2 / 3 / 3;
	}

	.grid-area-description {
		grid-area: 3 / 2 / 4 / 3;
	}
</style>

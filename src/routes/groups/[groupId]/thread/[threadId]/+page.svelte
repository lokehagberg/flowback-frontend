<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/stores';
	import type { Thread } from '$lib/Group/interface';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import Fa from 'svelte-fa';
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons';
	import { goto } from '$app/navigation';
	import { _ } from 'svelte-i18n';
	import Comments from '$lib/Comments/Comments.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import NewDescription from '$lib/Poll/NewDescription.svelte';
	import MultipleChoices from '$lib/Generic/MultipleChoices.svelte';
	import ReportPostModal from '$lib/Poll/ReportPostModal.svelte';
	import DeletePostModal from '$lib/Poll/DeletePostModal.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import ThreadVoting from '$lib/Thread/ThreadVoting.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';

	let thread: Thread | undefined = $state(undefined),
		reportModalShow = $state(false),
		deleteModalShow = $state(false);

	const source = new URLSearchParams(window.location.search).get('source');

	// Fixes a bug where clicking between threads (because of links or in notification) doesn't update page properly
	$effect(() => {
		const { threadId } = $page.params;
		getThread();
	});

	const getThread = async () => {
		const { json, res } = await fetchRequest(
			'GET',
			`group/thread/list?group_ids=${$page.params.groupId}&id=${$page.params.threadId}`
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Could not get Thread',
				success: false
			});
			return;
		}

		thread = json?.results[0];
		if (thread?.description === null) thread.description = '';
	};
</script>

<Layout centered>
	{#if thread}
		<div
			class="bg-white dark:bg-darkobject dark:text-darkmodeText rounded shadow poll-header-grid py-8 w-full max-w-[1200px]"
		>
			<button
				class="cursor-pointer bg-white dark:bg-darkobject dark:text-darkmodeText justify-center m-auto"
				onclick={() => {
					if (source === 'home') goto('/home');
					else if (source === 'group')
						goto(`/groups/${$page.params.groupId}?page=flow`);
					else if (
						source === 'delegate-history' ||
						source === 'notification' ||
						source === 'create'
					)
						history.back();
				}}
			>
				<Fa icon={faArrowLeft} />
			</button>

			<h1
				class="text-left text-2xl text-primary dark:text-secondary font-semibold"
			>
				{thread?.title}
			</h1>
			<div class="inline-flex gap-4 items-baseline">
				<NotificationOptions
					type="thread"
					id={thread?.id}
					api={`group/thread/${thread?.id}/subscribe`}
					categories={['thread_comment']}
					labels={['thread']}
				/>

				<MultipleChoices
					labels={[$_('Delete Thread'), $_('Report Thread')]}
					Class="text-black justify-self-center"
					functions={[
						() => (deleteModalShow = true),
						() => (reportModalShow = true)
					]}
					ClassInner="-translate-x-3/4"
					id="poll-header-multiple-choices"
				/>
			</div>

			<div class="grid-area-workgroup">
				{#if thread?.work_group}
					<span class="text-sm text-gray-500 dark:text-darkmodeText"
						>#{thread?.work_group?.name},
					</span>
				{/if}
				{#if thread?.created_at}
					<span class="text-sm text-gray-500 dark:text-darkmodeText">
						{new Date(thread?.created_at)
							.toISOString()
							.split('T')[0]
							.replace(/-/g, '.')}
					</span>
				{/if}
				<ThreadVoting bind:thread />
			</div>

			{#if thread?.description.length > 0}
				<div class="grid-area-description py-2">
					<NewDescription
						bind:description={thread.description}
						limit={3}
						lengthLimit={300}
					/>
				</div>
			{/if}
		</div>

		{#key thread.id}
			<Comments
				api={'thread'}
				Class="w-full max-w-[1000px] bg-white dark:bg-darkobject p-6 mt-6"
			/>
		{/key}
	{:else}
		<div
			class="p-4 bg-white dark:bg-darkobject dark:text-darkmodeText mt-4 rounded shadow"
		>
			<p>{$_('No thread found, it might have been deleted')}</p>
			<Button onClick={() => goto('groups')}><Fa icon={faArrowLeft} /></Button>
		</div>
	{/if}
</Layout>

<ReportPostModal
	post_type="thread"
	group_id={$page.params.groupId}
	post_id={thread?.id}
	post_title={thread?.title}
	post_description={thread?.description}
	bind:reportModalShow
/>

<DeletePostModal
	bind:deleteModalShow
	postId={thread?.id ?? ''}
	post_type="thread"
/>

<style>
	.poll-header-grid {
		display: grid;
		grid-template-columns: 0.3fr 4fr 0.3fr;
		grid-template-rows: 0.1fr 0.1fr 0.1fr 1fr;
	}

	.grid-area-description {
		grid-area: 4 / 2 / 4 / 3;
	}

	.grid-area-workgroup {
		grid-area: 3 / 2 / 3 / 3;
	}
</style>

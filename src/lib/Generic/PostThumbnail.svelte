<script lang="ts">
	import type { Snippet } from 'svelte';
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/state';
	import NotificationOptions from '$lib/Generic/NotificationOptions.svelte';
	import Fa from 'svelte-fa';
	import { faThumbTack } from '@fortawesome/free-solid-svg-icons';
	import { _ } from 'svelte-i18n';
	import NewDescription from '$lib/Poll/NewDescription.svelte';
	import { groupUserStore, type Thread } from '$lib/Group/interface';
	import MultipleChoices from '$lib/Generic/MultipleChoices.svelte';
	import { darkModeStore } from '$lib/Generic/DarkMode';
	import ReportPostModal from '$lib/Poll/ReportPostModal.svelte';
	import DeletePostModal from '$lib/Poll/DeletePostModal.svelte';
	import { goto } from '$app/navigation';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import DefaultBanner from '$lib/assets/default_banner_group.png';
	import ChatIcon from '$lib/assets/Chat_fill.svg';
	import { onThumbnailError } from '$lib/Generic/GenericFunctions';
	import { env } from '$env/dynamic/public';
	import type { poll } from '$lib/Poll/interface';

	let {
		post,
		children,
		icons
	}: { post: Thread | poll; children?: Snippet; icons?: Snippet } = $props();

	let reportModalShow = $state(false),
		deleteModalShow = $state(false),
		choicesOpen = $state(false);

	//When adminn presses the pin tack symbol, pin the thread
	const pinThread = async (_thread: Thread) => {
		const { json, res } = await fetchRequest(
			'POST',
			`group/thread/${_thread?.id}/update`,
			{
				pinned: !_thread?.pinned
			}
		);
		if (!res.ok) return;

		_thread.pinned = !_thread?.pinned;
		post = { ..._thread };
	};
</script>

<div
	class="bg-white dark:bg-darkobject dark:text-darkmodeText px-6 py-4 rounded-md"
	class:poll-thumbnail-shadow={!$darkModeStore}
>
	<div class="flex justify-between items-center">
		<div class="items-center flex w-full justify-between">
			<!-- Title. It is a button since this allows users to enter the Post -->
			<button
				class="pb-2 break-all cursor-pointer hover:underline text-primary dark:text-secondary text-xl text-left"
				onclick={() => {
					if (post?.group_joined)
						goto(
							`/groups/${post?.group_id}/thread/${post?.id}?source=${
								page.params.groupId ? 'group' : 'home'
							}`
						);
					else
						ErrorHandlerStore.set({
							message: 'You must join the group to access the thread',
							success: false
						});
				}}>{post?.title}</button
			>
			{#if post?.group_joined}
				<!-- Notification Options -->
				<div class="inline-flex gap-4 items-baseline">
					<NotificationOptions
						type="thread"
						api={`group/thread/${post?.id}`}
						categories={['comment']}
						id={post?.id}
						labels={['comment']}
					/>

					<!-- Pin thread button for admins -->
					{#if page.params.groupId && ($groupUserStore?.is_admin || post?.pinned)}
						<button
							class:cursor-pointer={$groupUserStore?.is_admin}
							onclick={() => pinThread(post)}
						>
							<Fa
								size="1.2x"
								icon={faThumbTack}
								color={post?.pinned ? '#999' : '#CCC'}
								rotate={post?.pinned ? '0' : '45'}
							/>
						</button>
					{/if}

					<MultipleChoices
						bind:choicesOpen
						labels={[$_('Delete Thread'), $_('Report Thread')]}
						functions={[
							() => (deleteModalShow = true),
							() => ((reportModalShow = true), (choicesOpen = false))
						]}
						Class="text-black justify-self-center"
						ClassInner="-translate-x-2/3 md:translate-x-0"
					/>
				</div>
			{/if}
		</div>
	</div>

	{#if !page.params.groupId}
		<button
			onclick={() => {
				if (post?.group_joined) goto(`/groups/${post?.group_id}`);
				else
					ErrorHandlerStore.set({
						message: 'You must join the group to access the group',
						success: false
					});
			}}
			class="pb-2 text-black flex items-center"
		>
			<img
				class="h-6 w-6 mr-1 rounded-full break-word"
				src={`${
					post?.group_image
						? `${env.PUBLIC_API_URL}${post?.group_image}`
						: DefaultBanner
				}`}
				alt={'thread Thumbnail'}
				onerror={(e) => onThumbnailError(e, DefaultBanner)}
			/>
			<span class="break-word text-sm text-gray-700 dark:text-darkmodeText"
				>{post?.group_name}</span
			>
		</button>
	{:else if post?.created_by?.user}
		<div class="text-black flex items-center">
			<!-- TODO: add "if group doesn't hide displaying creators" condition -->

			<!-- <img
					class="h-6 w-6 mr-1 rounded-full break-word"
					src={`${
						thread?.created_by?.user?.profile_image
							? `${env.PUBLIC_API_URL}${thread?.created_by?.user?.profile_image}`
							: DefaultPFP
					}`}
					alt={'thread Thumbnail'}
					on:error={(e) => onThumbnailError(e, DefaultPFP)}
				/> -->
			<span class="break-word text-sm text-gray-700 dark:text-darkmodeText"
				>{post?.created_by?.user?.username}</span
			>
		</div>
	{/if}

	<div class="flex gap-4 items-center mt-2 mb-4">
		<!-- Comment icon. When user clicks it leads to the comment section on the poll -->
		{#if post.group_joined}
			<a
				class="flex gap-1 items-center dark:text-darkmodeText hover:bg-gray-100 dark:hover:bg-slate-500 cursor-pointer text-sm"
				href={`/groups/${post?.group_id || page.params.groupId}/polls/${post?.id}?section=comments&source=${page.params.groupId ? 'group' : 'home'}`}
			>
				<img class="w-5 dark:invert" src={ChatIcon} alt="open chat" />
				<span class="inline">{post?.total_comments}</span>
			</a>
		{/if}

		{@render icons?.()}
	</div>

	{#if post?.description}
		<NewDescription
			limit={2}
			lengthLimit={700}
			description={post?.description}
		/>
	{/if}
	{@render children?.()}
</div>

<!-- TODO: Fix so group id is correct -->
<ReportPostModal
	post_type="thread"
	group_id={post?.group_id}
	post_id={post?.id}
	post_title={post?.title}
	post_description={post?.description}
	bind:reportModalShow
/>

<DeletePostModal bind:deleteModalShow postId={post?.id} post_type="thread" />

<style>
	.poll-thumbnail-shadow {
		box-shadow: 0 0 5px rgb(203, 203, 203);
	}
</style>

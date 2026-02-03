<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { type Thread } from '$lib/Group/interface';
	import ThreadVoting from './ThreadVoting.svelte';
	import PostThumbnail from '$lib/Generic/PostThumbnail.svelte';
	import { faGlobe, faLock } from '@fortawesome/free-solid-svg-icons';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';

	export let thread: Thread;
</script>

{#if thread}
	<PostThumbnail post={thread}>
		{#snippet icons()}
			{#if thread?.public}
				<HeaderIcon
					Class="!p-0 !cursor-default"
					icon={faGlobe}
					text={'Public Poll'}
				/>
			{:else}
				<HeaderIcon
					Class="!p-0 !cursor-default"
					icon={faLock}
					text={'Private Poll'}
				/>
			{/if}
		{/snippet}

		<ThreadVoting bind:thread />
	</PostThumbnail>
{/if}

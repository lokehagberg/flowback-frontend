<script lang="ts">
	import Timeline from './Timeline.svelte';
	import type { poll } from './interface';
	import { onMount } from 'svelte';
	import {page} from '$app/stores'

	export let poll: poll;
	onMount(() => {
		console.log(poll);
	});
	let onHoverGroup = false;
</script>

<!-- href={onHoverGroup ? (window.location.href = '/groups/1') : (window.location.href = '/poll')} -->
<a
	class="bg-white pt-3 pl-6 pr-6 pb-3 shadow-lg rounded cursor-pointer vote-thumbnail"
	href={onHoverGroup ? '/groups/1' : `${$page.params.groupId}/polls/${poll.id}`}
>
	<h1 class="text-left text-3xl p-2 pl-0">{poll.title}</h1>
	<p class="mt-2">
		{poll.description}
	</p>
	<Timeline dates={[new Date(poll.start_date), new Date(poll.end_date)]} displayDetails={false} />
	<div class="flex justify-between text-sm text-gray-600 mt-4">
		<p
			class="hover:underline"
			on:mouseover={() => (onHoverGroup = true)}
			on:mouseleave={() => (onHoverGroup = false)}
			on:click={() => (window.location.href = '/groups/1')}
			on:focus
		/>
	</div>
</a>

<style>
	.vote-thumbnail:hover {
		outline: 2px #ccc solid;
	}
</style>

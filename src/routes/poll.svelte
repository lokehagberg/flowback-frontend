<script lang="ts">
	import ProposalsRanked from '$lib/Poll/ProposalsRanked.svelte';
	import Header from '$lib/Header/Header.svelte';
	import Timeline from '$lib/Poll/Timeline.svelte';
	import Comments from '$lib/Poll/Comments.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import TestDraggable from '$lib/Poll/TestDraggable.svelte';
</script>

<Header />
<TestDraggable />
<div class="p-10 m-10 bg-white rounded shadow pt-6">
	<div class="flex gap-6">
		<h1 class="text-left text-3xl mt-auto mb-auto">Do a little Trolling</h1>
		<div class="mt-auto mb-auto"><HeaderIcon /></div>
		<div class="mt-auto mb-auto"><HeaderIcon /></div>
	</div>
	<div class="italic">Group Name</div>
	<ProposalsRanked />
	<Timeline />
	<Comments />
</div>

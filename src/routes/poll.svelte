<script lang="ts">
	import ProposalsRanked from '$lib/Poll/ProposalsRanked.svelte';
	import Header from '$lib/Header/Header.svelte';
	import Timeline from '$lib/Poll/Timeline.svelte';
	import Comments from '$lib/Poll/Comments.svelte';
</script>

<Header />
<div class="p-10 m-10 bg-gray-200">
	<h1>Destroy Lithuania</h1>
	<ProposalsRanked />
	<Timeline />
	<Comments />
</div>

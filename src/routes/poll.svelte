<script lang="ts">
	import ProposalsRanked from '$lib/Poll/ProposalsRanked.svelte';
	import Timeline from '$lib/Poll/Timeline.svelte';
	import Comments from '$lib/Poll/Comments.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Tag from '$lib/Group/Tag.svelte';
</script>

<Layout>
	<!-- <TestDraggable /> -->
	<div class="p-10 m-10 bg-white rounded shadow pt-6">
		<div class="flex gap-6">
			<h1 class="text-left text-3xl mt-auto mb-auto">How to prevent Co2 emissions in our county?</h1>
			<div class="mt-auto mb-auto"><HeaderIcon /></div>
			<div class="mt-auto mb-auto"><HeaderIcon /></div>
		</div>
		It has come to our attention that global warming is getting worse and we need solutions now.

		<div class="italic mt-4">Sigtuna County</div>
		<Tag Class="w-32 mb-4 mt-4" tag={"Environment"}/>
		<ProposalsRanked />
		<Timeline />
		<Comments />
	</div>
</Layout>

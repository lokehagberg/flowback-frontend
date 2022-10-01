<script lang="ts">
	import PollThumbnail from './PollThumbnail.svelte';
	export let Class = ""
</script>

<div class={`flex flex-col gap-6 ${Class}`}>
	<!-- <h1 class="text-3xl text-left">Flow</h1> -->
	<PollThumbnail />
	<!-- <PollThumbnail />
	<PollThumbnail />
	<PollThumbnail /> -->
</div>

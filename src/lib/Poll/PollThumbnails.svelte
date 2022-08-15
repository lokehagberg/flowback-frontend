<script lang="ts">
	import PollThumbnail from './PollThumbnail.svelte';
	export let className = ""
</script>

<div class={`flex flex-col gap-6 ${className}`}>
	<!-- <h1 class="text-3xl text-left">Flow</h1> -->
	<PollThumbnail />
	<PollThumbnail />
	<PollThumbnail />
	<PollThumbnail />
</div>

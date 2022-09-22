<script lang="ts">
import Timeline from "./Timeline.svelte";

	let onHoverGroup = false;
</script>

<!-- href={onHoverGroup ? (window.location.href = '/groups/1') : (window.location.href = '/poll')} -->
<a
	class="bg-white pt-3 pl-6 pr-6 pb-3 shadow-lg rounded cursor-pointer vote-thumbnail"
	href={onHoverGroup ? '/groups/1' : '/poll'}
	>	
	<h1 class="text-left text-3xl p-2 pl-0">
		How to prevent Co2 emissions in our county?
	</h1>
	<p class="mt-2">
		It has come to our attention that global warming is getting worse and we need solutions now.
	</p>
	<Timeline displayDetails={false}/>
	<div class="flex justify-between text-sm text-gray-600 mt-4">
		<p
			class="hover:underline"
			on:mouseover={() => (onHoverGroup = true)}
			on:mouseleave={() => (onHoverGroup = false)}
			on:click={() => (window.location.href = '/groups/1')}
			on:focus
		>
			Sigtuna County
		</p>
		<p>3 proposals</p>
		<p>2 comments</p>
	</div>
</a>

<style>
	.vote-thumbnail:hover {
		outline: 2px #ccc solid;
	}
</style>

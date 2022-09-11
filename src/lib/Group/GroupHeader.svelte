<script lang="ts">
	import { page } from '$app/stores';
	import type { SelectablePage } from './interface';
	console.log($page.params);
	export let selectedPage: SelectablePage;
</script>

<div class="relative">
	<div class="bg-red-500 h-56" />
	<div class="bg-blue-500 h-36 w-36 absolute -bottom-8 left-8" />
</div>
<div class="bg-white pt-12 flex justify-between align-middle pl-4 pr-4 pb-4">
	<h1
		class="text-3xl hover:underline cursor-pointer"
		on:click={() => (selectedPage = "flow")}
	>
		We hate Lithuania for no reason
	</h1>
	<p class="text-xl">50 members</p>
</div>

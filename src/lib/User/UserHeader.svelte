<script lang="ts">
	import { page } from '$app/stores';
	console.log($page.params);

    export let name:string
</script>

<div class="relative">
	<div class="bg-red-500 h-56" />
	<div class="bg-blue-500 h-36 w-36 absolute -bottom-8 left-8" />
</div>


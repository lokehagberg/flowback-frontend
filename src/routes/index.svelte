<svelte:head>
	<title>Welcome to Flowback</title>
</svelte:head>

<script lang="ts">
import { onMount } from "svelte";

	onMount(() => {
		if (localStorage.getItem("token")) window.location.href = "/home"
	})
	
</script>

<div class="flex justify-center">
<div class="flex flex-col items-center bg-white p-12 shadow rounded w-1/2 mt-12">
	<h1>Welcome to Flowback</h1>
	<!-- <h1 class="text-2xl">New and improved!</h1> -->
	<a
		href="/login"
		class="block text-center mt-4 w-1/2 bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mb-5 rounded cursor-pointer hover:no-underline hover:bg-blue-500"
		>Go to login page
	</a>
</div>
</div>
<script lang="ts">
	import { getRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';

	interface User {
		username: string;
		id: number;
		profile_image: null;
	}

	let users: User[] = [];

	onMount(async () => {
		const token = localStorage.getItem('token') || '';
		console.log(token);
		const response = await getRequest('users?limit=100', token);
		const responsejson = await response.json();
		users = responsejson.results;
	});
</script>

<div class="flex flex-col items-center gap-2 mb-24">
	{#if users.length !== 0}
		{#each users as user}
			<div
				class="flex bg-white p-2 hover:outline cursor-pointer"
				on:click={() => (window.location.href = `/user?id=${user.id}`)}
			>
				<div class="bg-red-500 w-10 h-10" />
				<div class="w-64 ml-10 hover:underline">{user.username}</div>
			</div>
		{/each}
	{/if}
</div>
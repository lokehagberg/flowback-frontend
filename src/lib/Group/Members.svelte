<script lang="ts">
	import { getRequest } from '$lib/FetchRequest';
	import Loader from '$lib/Generic/Loader.svelte';
	import { onMount } from 'svelte';

	interface User {
		username: string;
		id: number;
		profile_image: null;
	}

	let users: User[] = [];
	let loading = true

	onMount(async () => {
		const token = localStorage.getItem('token') || '';
		const response = await getRequest('users?limit=100', token);
		const responsejson = await response.json();
		users = responsejson.results;
		loading = false
	});
</script>

<Loader bind:loading={loading}/>
<div class="flex flex-col items-center gap-2 mb-24 bg-white shadow rounded">
	{#if users.length !== 0}
		{#each users as user}
			<a
				class="text-black flex bg-white p-2 hover:outline outline-gray-200 cursor-pointer w-full"
				href={`/user?id=${user.id}`}
			>
				<div class="bg-red-500 w-10 h-10" />
				<div class="w-64 ml-10 hover:underline">{user.username}</div>
			</a>
		{/each}
	{/if}
</div>

<script lang="ts">
	import Header from '$lib/Header/Header.svelte';
	import { page } from '$app/stores';
	import { fetchRequest, getRequest } from '$lib/FetchRequest';
    import { onMount } from 'svelte';

	onMount(async () => {
		const userId = $page.url.searchParams.get("id");
		const response = await getRequest(userId ? `user/${userId}` : "user");
	});
	
	const updateName = async () => {
		const response = await fetchRequest('POST', `user/update`, {username:"b"});
	}
</script>

<Header />

<button on:click={updateName}>Change name to b</button>

<div>{$page.params.id}</div>

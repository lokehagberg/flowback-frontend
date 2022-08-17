<script lang="ts">
	import Header from '$lib/Header/Header.svelte';
	import { page } from '$app/stores';
	import { fetchRequest, getRequest } from '$lib/FetchRequest';
    import { onMount } from 'svelte';

	onMount(async () => {
		const userId = $page.url.searchParams.get("id");
		console.log(userId)
		const response = await getRequest(`user`);
		console.log(response.json());
	});
	
	const updateName = async () => {
		const userId = $page.url.searchParams.get("id");
		console.log(userId)
		const response = await fetchRequest('POST', `user/update`, {username:"b"});
		console.log(response.json());

	}
</script>

<Header />

<button on:click={updateName}>Change name to b</button>

<div>{$page.params.id}</div>

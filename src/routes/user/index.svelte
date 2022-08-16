<script lang="ts">
	import Header from '$lib/Header/Header.svelte';
	import { page } from '$app/stores';
	import { getRequest } from '$lib/FetchRequest';
    import { onMount } from 'svelte';

	onMount(async () => {
		const userId = $page.url.searchParams.get("id");
		console.log(userId)
		const response = await getRequest(`user/${userId}`);
		console.log(response.json());
	});
</script>

<Header />

<div>{$page.params.id}</div>

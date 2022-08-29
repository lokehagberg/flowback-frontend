<script lang="ts">
	import Header from '$lib/Header/Header.svelte';
	import { page } from '$app/stores';
	import { fetchRequest, getRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import UserHeader from '$lib/User/UserHeader.svelte';
	import type { User } from '$lib/User/interfaces';
	import Layout from '$lib/Generic/Layout.svelte';

	let user: User = {
		banner_image: '',
		bio: '',
		email: '',
		profile_image: '',
		username: '',
		website: ''
	};

	onMount(async () => {
		const userId = $page.url.searchParams.get('id');
		const response = await getRequest(userId ? `user/${userId}` : 'user');
	});

	const updateName = async () => {
		const response = await fetchRequest('POST', `user/update`, { username: 'b' });
	};
</script>

<Layout>
	<UserHeader />
	<!-- <UserHeader name={'hi'} /> -->

	<div class="bg-white pt-12 flex justify-between align-middle pl-8 pr-4 pb-4">
		<h1 class="text-3xl hover:underline cursor-pointer">{user.username}</h1>
		<p>{user.bio}</p>
		<p>{user.website}</p>
	</div>

	<button on:click={updateName}>Change name to b</button>

	<div>{$page.params.id}</div>
</Layout>

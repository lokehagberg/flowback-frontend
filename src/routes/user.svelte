<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { User } from '$lib/User/interfaces';
	import Layout from '$lib/Generic/Layout.svelte';
	import DefaultPFP from '$lib/assets/Default_pfp.png';

	let user: User = {
		banner_image: '',
		bio: '',
		email: '',
		profile_image: '',
		username: '',
		website: '',
		id: 0
	};

	onMount(async () => {
		const userId = $page.url.searchParams.get('id');
		const { res, json } = await fetchRequest('GET', userId ? `users?id=${userId}` : 'user');
		console.log(json);
		user = userId ? json.results[0] : json;
	});

	const updateName = async () => {
		const { res } = await fetchRequest('POST', `user/update`, { username: 'b' });
	};

	console.log($page.url.searchParams.get('id'));
</script>

<Layout centering={true}>
	<div class="bg-red-500 h-48 w-full" />
	<div class="w-full md:w-2/3 bg-white shadow rounded p-8">
		<img src={DefaultPFP} class="h-36 w-36 inline" alt="avatar" />
		<h1 class="inline ml-8">{user.username}</h1>
		<!-- {#if user.website} -->
		<!-- <h2 class="inline">Website: {user.website}</h2> -->
		<!-- {/if} -->
		<p class="mt-8">
			{user.bio || 'This user has no bio'}
		</p>
	</div>
</Layout>

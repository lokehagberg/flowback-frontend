<script lang="ts">
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import { onMount } from 'svelte';
	import type { User } from '$lib/User/interfaces';
	import Layout from '$lib/Generic/Layout.svelte';

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
		console.log(json)
		user = userId ? json.results[0] : json
	});

	const updateName = async () => {
		const { res } = await fetchRequest('POST', `user/update`, { username: 'b' });
	};

	console.log($page.url.searchParams.get('id'));
</script>

<Layout>
	<div class="bg-red-500 h-48 mb-6" />
	<div>
		<div class="bg-blue-500 h-36 w-36" />
		<div class="w-1/2 ">
			<h1 class="inline">{user.username}</h1>
			<h2 class="inline">Website: Github.com</h2>
		</div>
	</div>

	<p>
		Lorem ipsum, dolor sit amet consectetur adipisicing elit. Perferendis assumenda ab dolores odit
		eos sunt nihil consequatur obcaecati? Animi, inventore neque non nulla odio nisi nam et a
		laborum quasi. Lorem, ipsum dolor sit amet consectetur adipisicing elit. Iusto, quam quod vitae
		rerum nulla officia perferendis provident ipsa repellat temporibus libero sit sequi eum optio at
		consequatur voluptatum porro natus!
	</p>
</Layout>

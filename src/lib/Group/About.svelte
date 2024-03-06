<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import { _ } from 'svelte-i18n';

	export let description: string;
	export let creatorId: number;
	let creator: any = { user: { username: '' } };

	onMount(() => {
		getCreator();
	});

	const getCreator = async () => {
		const { res, json } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/users?user_id=${creatorId}`
		);
		if (res.ok) creator = json.results[0];
	};
</script>

<div class="bg-white dark:bg-darkobject dark:text-darkmodeText p-6 text-xl rounded shadow">
	<p>{description}</p>
	<span>{$_('Creator')}: {creator.user.username}</span>
</div>

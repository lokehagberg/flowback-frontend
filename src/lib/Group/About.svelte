<script lang="ts">
	import { onMount } from "svelte";
	import {page} from '$app/stores'
	import { fetchRequest } from "$lib/FetchRequest";
	import type { GroupUser } from "$lib/User/interfaces";

	export let description:string
	export let creatorId:number;
	let creator:any = {username:""};

	onMount(() => {
		getCreator();
	})

	const getCreator = async () => {
		const {res, json} = await fetchRequest('GET', `group/${$page.params.groupId}/users?user_id=${creatorId}`)
		if (res.ok) creator = json.results[0]
	}
</script>

<div class="bg-white p-6 text-xl rounded shadow p-6">
	<p>{description}</p>
	<span>Creator: {creator.username}</span>
</div>

<script lang="ts">
	import { fetchRequest } from "$lib/FetchRequest";
    import { page } from '$app/stores';
	import { onMount } from "svelte";

    onMount(async () => {
        const res = await fetchRequest('GET', `group/${$page.params.groupId}/tags`)
        const json = await res.json();
		console.log(json.results);
    })

</script>

<div class="bg-white rounded shadow p-6">


</div>
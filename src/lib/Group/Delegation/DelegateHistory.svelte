<script lang="ts">
	import { fetchRequest } from "$lib/FetchRequest";
	import Loader from "$lib/Generic/Loader.svelte";
	import { onMount } from "svelte";

    export let history:null|number;

    let loading = false

    const getDelegateHistory = async () => {
        loading = true;
        const { res, json } = await fetchRequest('GET', `group/delegate/history?id=${history}`);
        loading = false;
    }

    onMount(() => {
        getDelegateHistory();
    })

</script>

<Loader bind:loading>
<div>delegate history!</div>
</Loader>
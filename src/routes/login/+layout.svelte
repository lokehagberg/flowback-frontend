<script lang="ts">
	import { onDestroy, onMount } from "svelte";

    onMount(() => {
        const header = document.getElementById("header")
        if (!header) return;

        header!.style.display = "none"
    })

    onDestroy(() => {
        const header = document.getElementById("header")
        if (!header) return;

        header!.style.display = "block"
        console.log("destroyer")
    })
</script>

<main>
    <slot/>
</main>


<style>

    .header {
        display:none;
        visibility: hidden;
    }

</style>
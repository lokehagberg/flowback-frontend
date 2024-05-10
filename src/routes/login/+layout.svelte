<script lang="ts">
	import { onMount } from "svelte";

    onMount(() => {
        const header = document.getElementById("header")
        if (!header) return;

        header!.style.display = "none"
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
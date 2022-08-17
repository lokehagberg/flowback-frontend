<script lang="ts">
	const navs = [
        {title:'User profile', action: () => {window.location.href="/user"}}];
</script>

<div class="absolute right-0 h-full bg-gray-500" >

    {#each navs as nav}
        <div on:click={nav.action}>{nav.title}</div>
    {/each}

</div>

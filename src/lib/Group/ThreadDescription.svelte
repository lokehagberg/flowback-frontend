<script lang="ts">
    import { page } from '$app/stores';

    export let limit:number, description:string = "", onHoverGroup:boolean = false, Class = ""

    let readMore = false
</script>

<p class={`mt-2 whitespace-pre-wrap break-words mb-4 dark:text-darkmodeText ${Class}`}>
    {#if readMore}
        <a
            class="cursor-pointe text-black hover:underline"
            >
            {description}
        </a>

        {#if description.length > limit}
            <!-- svelte-ignore a11y-no-static-element-interactions -->
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <span
                class="hover:underline cursor-pointer text-gray-600 font-bold ml-3"
                on:click={() => (readMore = false)}>Show less...</span
            >
        {/if}
    {:else}
        <a
            class="cursor-pointe text-black hover:underline"
            
        >
            {description.slice(0, limit)}
        </a>
        <!-- svelte-ignore a11y-no-static-element-interactions -->
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        {#if description.length > limit}
            ...<span
                class="hover:underline cursor-pointer text-gray-600 font-bold ml-3"
                on:click={() => (readMore = true)}>Show more...</span
            >
        {/if}
    {/if}
</p>
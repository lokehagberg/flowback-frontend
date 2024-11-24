<script lang="ts">
	import type { poll } from "./interface";
    import { page } from '$app/stores';
    import { _ } from 'svelte-i18n';

    export let limit:number, poll:any, onHoverGroup:boolean = false, Class = ""

    let readMore = false
</script>

<p class={`mt-2 whitespace-pre-wrap break-words mb-4 dark:text-darkmodeText ${Class}`}>
    {#if readMore}
        <a
            class="cursor-pointe hover:underline"
            href={onHoverGroup
                ? '/groups/1'
                : `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`}
        >
            {poll.description}
        </a>
        {#if poll.description.length > limit}
            <!-- svelte-ignore a11y-no-static-element-interactions -->
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <span
                class="hover:underline cursor-pointer text-gray-600 font-bold ml-3"
                on:click={() => (readMore = false)}>{$_("Show less")}...</span
            >
        {/if}
    {:else}
        <a
            class="cursor-pointe hover:underline"
            href={onHoverGroup
                ? '/groups/1'
                : `/groups/${poll.group_id || $page.params.groupId}/polls/${poll.id}`}
        >
            {poll.description.slice(0, limit)}
        </a>

        <br/>
        {#if poll.description.length > limit}
            ...<span
                class="hover:underline cursor-pointer text-gray-600 font-bold ml-3"
                on:click={() => (readMore = true)}>{$_("Show more")}...</span
            >
        {/if}
    {/if}
</p>
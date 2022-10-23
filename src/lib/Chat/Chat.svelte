<script lang="ts">
	import TextArea from "$lib/Generic/TextArea.svelte";
	import { onMount } from "svelte";
    import type {Message} from './interfaces'
    
    let messages:Message[] = [{message:"haii", time:new Date()}]
    let socket:WebSocket
    
    onMount(async () => {
        socket = (await import('./Socket')).socket
    })

</script>
<div class="fixed bg-white shadow p-8">
    {#each messages as message}
        {message.message}
    {/each}
	<TextArea label="write a message" />
</div>

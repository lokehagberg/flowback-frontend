<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
    import { faCircle } from "@fortawesome/free-solid-svg-icons/faCircle"
    export let icon = faCircle
    export let text = "icon"
</script>

<style>
    .centeringFix{
        position:absolute;
        width:100px;
        left:calc(50% - 50px);
        text-align: center;
    }
</style>

<div class="p-1 relative">
    <Fa icon={icon} />
    <div class="border border-black centeringFix" style="">
        {text}
    </div>
</div>
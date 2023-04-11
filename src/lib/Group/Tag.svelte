<script lang="ts">

    export let tag:string
    export let Class:string = ""
    export let onclick = () => {}

</script>

<div class={"select-none text-xs tag text-center bg-gray-400 text-white pl-4 pr-4 pt-1 pb-1 break-words rounded " + Class} on:click={onclick}>{tag}</div>

<style>
    .tag{
        transition: background-color 400ms cubic-bezier(0.075, 0.82, 0.165, 1)
    }
</style>
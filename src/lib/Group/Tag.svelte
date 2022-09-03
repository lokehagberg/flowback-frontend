<script lang="ts">

    export let tag:string
    export let className:string = ""

</script>

<div class={"select-none tag text-center w-full bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 rounded " + className}>{tag}</div>

<style>
    .tag{
        transition: background-color 400ms cubic-bezier(0.075, 0.82, 0.165, 1)
    }
</style>
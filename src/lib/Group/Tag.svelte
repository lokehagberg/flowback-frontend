<script lang="ts">

    export let tag:string
    export let className:string = ""

</script>

<div class={"tag text-center w-full bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 rounded cursor-pointer " + className}>{tag}</div>


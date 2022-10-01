<script lang="ts">
import ButtonPrimary from "$lib/Generic/ButtonPrimary.svelte";
import TextInput from "$lib/Generic/TextInput.svelte";
</script>

<div class="bg-white p-6 text-xl rounded shadow p-6">
    <form on:submit|preventDefault={() => {console.log("test")}} class="flex flex-col gap-4">
        <TextInput label="Title" />
        <TextInput label="Post" />
        <ButtonPrimary type="submit" Class="mt-4"/>
    </form>
</div>
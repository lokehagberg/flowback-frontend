<script lang="ts">
    import TextInput from "./TextInput.svelte";
    
    let username:string
    let password:string

    async function logIn(){
    }
</script>

<form class="flex flex-col items-center" on:submit|preventDefault={logIn}>
	<TextInput label={'Username'} bind:value={username} />
	<TextInput label={'Password'} bind:value={password} />

    <input
    type="submit"
    class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer" />
</form>
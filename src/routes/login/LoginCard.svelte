<script lang="ts">
    import TextInput from "./TextInput.svelte";
    
    let username:String
    let password:String

    async function logIn(){
    }
</script>

<form class="flex flex-col items-center">
	<TextInput label={'Username'} bind:value={username} />
	<TextInput label={'Password'} bind:value={password} />

	<button
		on:click={logIn}
		class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded">Submit</button
	>
</form>
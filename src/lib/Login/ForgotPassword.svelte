<script lang="ts">
import { fetchRequest } from "$lib/FetchRequest";

    import TextInput from "../Generic/TextInput.svelte";
    
    export let selectedPage:string;
    let email:string
    async function sendCode(e:any){
        e.preventDefault();
		const response = await fetchRequest("POST", "forgot_password", {email}, false)
        selectedPage = "NewPassword"
    }
</script>

<form class="gap-6 p-6 flex flex-col items-center" on:submit|preventDefault={sendCode}>
	<TextInput label={'E-mail'} bind:value={email} required={true}/>

    <input
    type="submit"
    class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer" />
</form>


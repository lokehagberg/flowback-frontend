<script lang="ts">
    import TextInput from "../Generic/TextInput.svelte";
    
    export let selectedPage:string;
    let email:string
    async function sendCode(e:any){
        e.preventDefault();
		const response = await fetch('https://v2.flowback.org/forgot_password', {
			method: 'POST',
			headers: {
				Accept: 'application/json',
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({
				email
			})
		});
		console.log(response)
        selectedPage = "NewPassword"
    }
</script>

<form class="flex flex-col items-center" on:submit|preventDefault={sendCode}>
	<TextInput label={'E-mail'} bind:value={email} />

    <input
    type="submit"
    class="inline bg-blue-600 text-white pl-6 pr-6 pt-2 pb-2 mt-5 mb-5 rounded cursor-pointer" />
</form>


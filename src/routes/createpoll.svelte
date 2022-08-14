<script>
import ButtonPrimary from "$lib/Generic/ButtonPrimary.svelte";
import TextInput from "$lib/Generic/TextInput.svelte";
import Header from "$lib/Header/Header.svelte";



const createPoll = () => {
    console.log("poll created!")

}
</script>



<Header/>



<form on:submit|preventDefault={createPoll} class="flex items-start justify-center gap-8 mt-8 ml-8 mr-8">

    <div class="bg-white p-6 shadow-xl flex flex-col gap-6 w-2/3">
        <h1 class="text-2xl">Create a poll</h1>
        <TextInput label="Title"/>
        <TextInput label="Description"/>
        <ButtonPrimary>Create Poll</ButtonPrimary>
    </div>
    <div class="w-1/3">
    <div class="bg-white p-6 shadow-xl flex flex-col gap-6">
        <ButtonPrimary>Ranking</ButtonPrimary>
        <ButtonPrimary>Time</ButtonPrimary>
    </div>
    <div class="bg-white p-6 shadow-xl mt-4">
        Ranking poll is Lorem ipsum dolor sit amet consectetur adipisicing elit. Natus ipsam incidunt consequuntur culpa facere cupiditate. Inventore eum tempore libero, natus animi itaque omnis eaque tempora quod maiores, dolores velit dolorem?
    </div>
</div>
</form>
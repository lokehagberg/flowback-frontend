<script lang="ts">
	import { page } from "$app/stores";
	import { fetchRequest } from "$lib/FetchRequest";
	import Button from "$lib/Generic/Button.svelte";

    const vote = () => {

        fetchRequest(`POST`, `group/poll/${$page.params.pollId}/proposal/vote/delegate/update`, {
            proposals: [5,6,7],
            scores:[1,2,3]
        })
        
    }

</script>

<div>

    <Button action={vote}/>
</div>
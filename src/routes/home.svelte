<script>
import { getRequest } from "$lib/FetchRequest";
import { onMount } from "svelte";

  import Header from "../lib/Header/Header.svelte";

  onMount(async () => {
    const response = await getRequest("users", localStorage.getItem("token")||"")
    console.log(response.json())
  })
</script>

<Header />
<div>welcome home</div>
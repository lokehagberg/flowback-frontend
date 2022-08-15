<script>
	import { getRequest } from '$lib/FetchRequest';
	import PollThumbnail from '$lib/Poll/PollThumbnail.svelte';
import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import { onMount } from 'svelte';
	import Header from '../lib/Header/Header.svelte';


</script>

<Header />
<div class=" flex  justify-center mt-10">
<PollThumbnails className="w-2/3 justify-center"/>
</div>

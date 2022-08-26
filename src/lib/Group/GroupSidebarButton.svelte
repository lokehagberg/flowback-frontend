<script lang="ts">
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	import Fa from 'svelte-fa/src/fa.svelte';

	export let text: string;
	export let action = () => {};

	let hovering = false;
</script>

<div
	on:mouseover={() => (hovering = true)}
	on:focus
	on:mouseleave={() => (hovering = false)}
	class="flex item-center items-center  cursor-pointer hover:underline pt-3 pb-3"
	on:click={action}
>
	<Fa icon={faPoll} color={hovering ? "#015BC0" : "black"} />
	<div class="ml-2">
		{text}
	</div>
</div>

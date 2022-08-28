<script lang="ts">
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	import Fa from 'svelte-fa/src/fa.svelte';

	export let text: string;
	export let action = () => {};

	let hovering = false;
</script>

<div
	on:mouseover={() => (hovering = true)}
	on:mouseleave={() => (hovering = false)}
	on:focus
	on:click={action}
	class="select-none flex item-center items-center hover:outline outline-gray-200 cursor-pointer p-4"
>
	<Fa icon={faPoll} color={hovering ? "#015BC0" : "black"} />
	<div class="ml-2">
		{text}
	</div>
</div>

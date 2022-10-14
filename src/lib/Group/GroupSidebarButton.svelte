<script lang="ts">
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';

	export let text: string;
	export let action = () => {};
	export let icon = faPoll

	let hovering = false;
</script>

<div
	on:mouseover={() => (hovering = true)}
	on:mouseleave={() => (hovering = false)}
	on:focus
	on:click={action}
	class="select-none flex item-center items-center hover:outline outline-gray-200 cursor-pointer p-4"
>
	<Fa {icon} color={hovering ? "#015BC0" : "black"} />
	<div class="ml-2">
		{$_(text)}
	</div>
</div>

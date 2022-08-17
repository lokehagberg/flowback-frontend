<script lang="ts">
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	import Fa from 'svelte-fa/src/fa.svelte';

	export let text: string;
	export let action = () => {};
</script>

<div class="flex item-center items-center">
	<Fa icon={faPoll} />
	<div class="ml-2 cursor-pointer hover:underline" on:click={action}>
		{text}
	</div>
</div>

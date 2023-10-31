<script lang="ts">
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faFile } from '@fortawesome/free-solid-svg-icons/faFile';
	export let name: string;
	$: type = name.slice(name.lastIndexOf('.') + 1);
</script>

<div class="flex text-blue-400">
	<Fa icon={faFile} /> <span class="text-black"> {name}</span>
</div>

<style>
	span {
		padding: 0 0 0 1.5em;
		background: 0 0.1em no-repeat;
		background-size: 1em 1em;
	}
</style>

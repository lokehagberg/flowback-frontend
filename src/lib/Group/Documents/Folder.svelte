<script lang="ts">
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
import File from './File.svelte';
import { faFolder } from '@fortawesome/free-solid-svg-icons/faFolder';
    type File = {
        files?:File[],
        name:string
    }

	export let expanded = false;
	export let name:string;
	export let files:File[];

	function toggle() {
		expanded = !expanded;
	}
</script>

<div class="flex text-blue-600">
    <Fa icon={faFolder}/>
    <span on:click={toggle} class="text-black">{name}</span>
</div>

{#if expanded}
	<ul>
		{#each files as file}
			<li>
				{#if file.files}
					<svelte:self {...file} />
				{:else}
					<File {...file} />
				{/if}
			</li>
		{/each}
	</ul>
{/if}

<style>
	span {
		padding: 0 0 0 1.5em;
		background-size: 1em 1em;
		font-weight: bold;
		cursor: pointer;
	}

	ul {
		padding: 0.2em 0 0 0.5em;
		margin: 0 0 0 0.5em;
		list-style: none;
		border-left: 1px solid #eee;
	}

	li {
		padding: 0.2em 0;
	}
</style>

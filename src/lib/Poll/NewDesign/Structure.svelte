<script lang="ts">
	import { onMount } from "svelte";
	import type { poll } from "../interface";
	import Timeline from "./Timeline.svelte";

    export let poll:poll;

	let genericStyle = 'bg-white p-6';
    onMount(() => {
        console.log(poll)
    })
    $: console.log(poll);
    
</script>


{#if poll}
<div class="poll-grid p-12">
	
	<Timeline displayDetails={false} bind:poll pollType={4} Class="timeline-grid" />

	{#if $$slots.left}
		<div class={`${genericStyle}`}>
			<slot name="left" />
		</div>
	{/if}

	{#if $$slots.right}
		<div class={`${genericStyle}`}>
			<slot name="right" />
		</div>
	{/if}

	{#if $$slots.bottom}
		<div class={`${genericStyle} bottom-grid`}>
			<slot name="bottom" />
		</div>
	{/if}
</div>

<style>
	.poll-grid {
		grid-template-columns: 0.2fr 1fr 1fr;
		grid-template-rows: 1fr 1fr;
		display: grid;
		gap: 20px;
	}

	.timeline-grid {
		grid-area: 1 / 1 / 3 / 1;
	}

	.bottom-grid {
		grid-area: 2 / 2 / 2 / 4;
	}
</style>
{/if}
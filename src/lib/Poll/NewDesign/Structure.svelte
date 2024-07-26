<script lang="ts">
	let genericStyle = 'bg-white p-6';
</script>

<div class="poll-grid p-12">
	<div class="bg-gray-500 w-[10px] h-[800px] timeline-grid" />

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

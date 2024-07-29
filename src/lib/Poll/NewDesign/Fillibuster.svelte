<script lang="ts">
	let x: { name: any }[] = [{ name: 1 }];
</script>

<slot />
{#each x as item}
	<slot name="hi" {item} />
{/each}

{#if $$slots.hi}
	HIII
{/if}

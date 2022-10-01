<script lang="ts">
	export let Class: string = '';

	let error: string | null;
	export let status: number = 0;
	export let statusMessages: Record<number, string | null> = {
		0: null,
		400: 'You sent the wrong data',
		500: 'Server Error'
	};

	$: error = statusMessages[status];
</script>

{#if error !== null && error !== undefined}
	<div class={`border border-red-500 w-full pt-2 pb-2 text-center rounded ${Class}`}>
		{error}
	</div>
{/if}

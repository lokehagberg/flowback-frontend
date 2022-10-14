<script lang="ts">
	import { _ } from 'svelte-i18n';

	export let Class = '';

	let message: string | null;
	export let status: number = 0;
	export let statusMessages: Record<number, string | null> = {
		0: null,
		200: 'Success',
		400: 'You sent the wrong data',
		500: 'Server Error'
	};

	$: message = statusMessages[status];
	$: console.log(status, 'STATUS');
</script>

{#if message !== null && message !== undefined}
	<div
		class={`border w-full pt-2 pb-2 text-center rounded ${Class} ${
			status === 200 ? 'border-green-500' : 'border-red-500'
		}`}
	>
		{$_(message)}
	</div>
{/if}

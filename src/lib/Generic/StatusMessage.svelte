<script lang="ts">
	import { _ } from 'svelte-i18n';

	export let Class = '';

	export let status: {message: string | null, success:boolean};
</script>

{#if status !== null && status !== undefined}
	<div
		class={`border w-full pt-2 pb-2 text-center rounded ${Class} ${
			status.success ? 'border-green-500' : 'border-red-500'
		}`}
	>
		{$_(status.message || (status.success ? "Success" :"Something went wrong"))}
	</div>
{/if}

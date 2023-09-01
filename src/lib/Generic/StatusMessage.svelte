<script lang="ts">
	import { _ } from 'svelte-i18n';
	import type { StatusMessageInfo } from './GenericFunctions';

	export let Class = '',
		status: StatusMessageInfo | undefined | null,
		disableSuccess = false;
</script>

{#if status !== null && status !== undefined}
	{#if (disableSuccess && !status.success) || !disableSuccess}
		<div
			class={`border w-full pt-2 pb-2 text-center rounded ${Class} ${
				status.success ? 'border-green-500' : 'border-red-500'
			}`}
		>
			{$_(status.message || (status.success ? 'Success' : 'Something went wrong'))}
		</div>
	{/if}
{/if}

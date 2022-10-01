<script lang="ts">
	let error: string | null = null;
	export let status: number;
    export let Class:string = ""

	$: {
		if (status === 400) error = 'Unable to Login with provided credentials';
		else if (status === 500) error = 'Server Error';
	}
</script>

{#if error !== null}
	<div class={`border border-red-500 w-full pt-2 pb-2 text-center rounded${Class}`}>
		{error}
	</div>
{/if}

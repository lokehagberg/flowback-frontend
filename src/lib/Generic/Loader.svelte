<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faSpinner } from '@fortawesome/free-solid-svg-icons/faSpinner';
    
    export let loading:boolean
</script>

<div class="loader absolute hidden" class:hidden={!loading}>
	<Fa icon={faSpinner} spin={true} size="4x" />
</div>

<style>
	.loader {
		color: var(--primary-color);
	}
</style>

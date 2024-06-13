<script lang="ts">
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faSpinner } from '@fortawesome/free-solid-svg-icons/faSpinner';

	export let loading: boolean,
		Class: string = '',
		delay = 1000;
	let isLoading: boolean, currentTimer: NodeJS.Timeout;

	$: if (loading)
		currentTimer = setTimeout(() => {
			if (loading) {
				isLoading = true;
				// loading = false;
			}
		}, delay);

	$: if (!loading) {
		clearTimeout(currentTimer);
		isLoading = false
	}
</script>

<div class={`w-full relative ${isLoading && 'contrast-50'} ${Class}`}>
	<div
		class:hidden={!isLoading}
		class="conotrast-100 z-10 text-blue-500 absolute hidden left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2"
	>
		<Fa icon={faSpinner} spin={true} size="4x" />
	</div>
	<slot />
</div>

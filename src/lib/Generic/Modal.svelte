<script lang="ts">
	import CrossButton from './CrossButton.svelte';

	export let open = false;
</script>

<div
	id="popup-modal"
	tabindex="-1"
	class:hidden={!open}
	class="overflow-y-auto overflow-x-hidden fixed top-0 right-0 left-0 z-50 md:inset-0 h-modal md:h-full"
>
	<div class="relative p-4 w-full max-w-md h-full md:h-auto">
		<div class="relative bg-white rounded-lg shadow dark:bg-gray-100">
			<div class="border-b-2 border-gray-300 border-solid">
                <slot name="header">
				</slot>
			</div>
			<div class="p-6 text-center">
				<slot name="body">
				</slot>
				<slot name="footer">
				</slot>
			</div>
		</div>
	</div>
</div>

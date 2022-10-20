<script lang="ts">
	import CrossButton from './CrossButton.svelte';
	export let open = false;
</script>

<div
	class:hidden={!open}
	id="popup-modal"
	tabindex="-1"
	class="bg-transparent overflow-y-auto overflow-x-hidden fixed left-1/2 -translate-x-1/2 top-1/2 -translate-y-1/2 z-50 md:inset-0 h-modal md:h-full"
>
	<div class="shadow-xl border border-gray-300 rounded bg-white relative p-4 w-full max-w-md h-full md:h-auto">
		<div class="text-xl border-b-2 border-gray-300 border-solid">
			<slot name="header" />
			<CrossButton action={() => (open = false)} />
		</div>
		<div class="p-6 text-center">
			<slot name="body" />
		</div>
		<slot name="footer" />
	</div>
</div>

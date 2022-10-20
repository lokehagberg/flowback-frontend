<script lang="ts">
	import CrossButton from './CrossButton.svelte';
	export let open = false;
</script>

<div
	class:hidden={!open}
	id="popup-modal"
	tabindex="-1"
	class="bg-transparent overflow-y-auto overflow-x-hidden fixed top-1/4  translate-x-1/4 z-50 md:inset-0 h-modal md:h-full"
>
	<div class="bg-white relative p-4 w-full max-w-md h-full md:h-auto">
		<div class="text-xl border-b-2 border-gray-300 border-solid">
			<slot name="header" />
			<CrossButton action={() => (open = false)} />
		</div>
		<div class="p-6 text-center">
			<slot name="body" />
			<slot name="footer" />
		</div>
	</div>
</div>

<script lang="ts">
	import { _ } from 'svelte-i18n';
	import type { poppup } from './Poppup';

	export let poppup: poppup = {
		message: 'Task performed successfully',
		success: true
	};

	let show = false;

	$: poppup && successPoppupAnimation();

	const successPoppupAnimation = () => {
		show = true;
		setTimeout(() => {
			show = false;
		}, 4000);
	};
</script>

<div class="fixed bottom-5 right-5 z-50" hidden={!show}>
	<div
		id="popup"
		class={`${
			poppup.success ? 'bg-green-600' : 'bg-red-600'
		} text-white px-4 py-2 rounded-md shadow-md opacity-0 transition-opacity duration-300 transform translate-y-3`}
		class:show
	>
		{$_(poppup.message)}
	</div>
</div>

<style>
	#popup.show {
		opacity: 1;
		transform: translate-y(0);
	}
</style>

<script lang="ts">
	import { _ } from 'svelte-i18n';

	export let poppup = {
		show: false,
		message: 'Task performed successfully',
		success: true
	};

	const successPoppupAnimation = () => {
		setTimeout(() => {
			poppup.show = false;
		}, 4000);
	};

	$: poppup.message && successPoppupAnimation();
</script>

<div class="fixed bottom-5 right-5 z-50" hidden={!poppup.show}>
	<div
		id="popup"
		class={`${
			poppup.success ? 'bg-green-600' : 'bg-red-600'
		} text-white px-4 py-2 rounded-md shadow-md opacity-0 transition-opacity duration-300 transform translate-y-3`}
		class:show={poppup.show}
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

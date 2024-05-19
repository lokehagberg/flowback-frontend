<!-- Depricated, change to Poppup.svelte -->
<script lang="ts">
	import { _ } from 'svelte-i18n';

	export let show = false, message = "Task performed successfully";

	const successPoppupAnimation = () => {
		setTimeout(() => {
			show = false;
		}, 7000);
	};

	$: show && successPoppupAnimation();

	$: message && successPoppupAnimation();
</script>

<div class="fixed bottom-5 centered text-center z-50" hidden={!show}>
	<div
		id="popup"
		class="bg-green-600 text-white px-4 py-2 rounded-md shadow-md opacity-0 transition-opacity duration-300 transform translate-y-3"
		class:show
	>
		{$_(message)}
	</div>
</div>

<style>
	#popup.show {
		opacity: 1;
		transform: translate-y(0);
	}

	.centered {
    position: fixed;
    left: 50%;
    transform: translate(-50%, 0);
}
</style>
